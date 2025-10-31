# sprinthub_with_stealth.py
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Caminhos — ajuste se necessário
CHROMEDRIVER_PATH = r"C:\Drivers\chromedriver140\chromedriver.exe"
COMET_PATH = r"C:\Users\Maqplan\AppData\Local\Perplexity\Comet\Application\comet.exe"
USER_DATA_DIR = r"C:\Users\Maqplan\AppData\Local\Perplexity\Comet\AutomationProfile"

# Configuração do Selenium + stealth
options = Options()
options.binary_location = COMET_PATH
options.add_argument(f"--user-data-dir={USER_DATA_DIR}")

# flags de estabilidade
options.add_argument("--remote-debugging-port=6668")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")
options.add_argument("--start-maximized")
options.add_argument("--no-first-run")
options.add_argument("--no-default-browser-check")
options.add_argument("--disable-gpu-sandbox")

# stealth flags para reduzir detecção
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option("useAutomationExtension", False)

# Cria o serviço com o ChromeDriver local
service = Service(CHROMEDRIVER_PATH)

# Inicia o WebDriver
driver = webdriver.Chrome(service=service, options=options)
driver.set_window_size(1400, 900)

# ------------- stealth runtime: sobrescreve navigator.webdriver -------------
# Deve ser executado antes de carregar qualquer página (ideia: já foi)
driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
    "source": """
        // Remove navigator.webdriver
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined
        });
        // Algumas páginas checam por plugins ou languages — você pode adicionar mais shims se necessário
        Object.defineProperty(navigator, 'plugins', { get: () => [1,2,3,4,5] });
        Object.defineProperty(navigator, 'languages', { get: () => ['pt-BR', 'pt'] });
    """
})
# ---------------------------------------------------------------------------

print("✅ Comet iniciou com o perfil de automação (stealth ativo).")

# -------------------------------------------------------
# Etapa 1: Abrir SprintHub (caso não abra automaticamente)
driver.get("https://sprinthub.app/sh/crm?func=dashboard")

# Aguarda a página carregar
wait = WebDriverWait(driver, 20)

try:
    # Exemplo de interação: localizar e clicar no card pelo texto
    card_xpath = "//div[normalize-space()='4865 - Melhoria | Controle de credito cliente PDV']"
    card = wait.until(EC.element_to_be_clickable((By.XPATH, card_xpath)))
    # scrollIntoView só pra garantir visibilidade
    driver.execute_script("arguments[0].scrollIntoView({block:'center'});", card)
    time.sleep(0.5)
    card.click()
    print("✅ Card encontrado e clicado com sucesso!")

except Exception as e:
    print("⚠️ Não foi possível clicar no card:", e)

# Aguarda para inspeção manual antes de fechar
time.sleep(10)
driver.quit()
