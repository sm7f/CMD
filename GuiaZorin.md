# 🧩 Guia Completo de Instalação e Otimização do Zorin OS
Versão: 1.0  
Autor: Herberth  
Finalidade: Criar padrão de configuração para todos os computadores da rotina.

---

# 1. Preparação Inicial

## 1.1 Atualizar o Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

## 1.2 Instalar Ferramentas Essenciais
```bash
sudo apt install curl wget git gparted neofetch htop software-properties-gtk -y
```

---

# 2. Codecs e Drivers (Suporte a vídeo, áudio e fontes)

## 2.1 Instalar o pacote completo de multimídia
```bash
sudo apt install ubuntu-restricted-extras -y
sudo apt install zorin-os-restricted-extras -y
```

## 2.2 Aceitar EULA automaticamente (se travar)
```bash
sudo echo ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt -f install
```

---

# 3. Gravador de Tela

## 3.1 Gravador nativo do Zorin (GNOME)
Atalhos:
- Ctrl + Alt + Shift + R (iniciar/parar)

## 3.2 Kooha (recomendado)
```bash
flatpak install flathub io.github.seadve.Kooha
```

---

# 4. Permissões e Acesso Root

## 4.1 Sudo sem senha (opcional)
```bash
sudo visudo
```
Alterar:
```
%sudo  ALL=(ALL:ALL) NOPASSWD:ALL
```

## 4.2 Ajustar permissões de pastas
```bash
sudo chown -R $USER:$USER /pasta
sudo chmod -R 775 /pasta
```

---

# 5. VM com KVM + Virt-Manager

## 5.1 Instalar KVM
```bash
sudo apt install qemu-kvm virt-manager virt-viewer ovmf bridge-utils -y
```

## 5.2 Drivers VirtIO
Baixar:
https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

## 5.3 Criar VM

1. ISO do Windows (não virtio-win)
2. RAM 2GB, CPU 1–2
3. Disco 20GB
4. Personalizar antes de instalar

### Configurações importantes:
- Firmware: BIOS ou UEFI sem Secure Boot  
- Boot: CDROM primeiro  
- Disco: SATA na instalação  

---

# 6. Programas Essenciais

## 6.1 SimpleScreenRecorder
```bash
sudo apt install simplescreenrecorder
```

## 6.2 OBS
```bash
sudo apt install obs-studio
```

## 6.3 VSCode como root
```bash
sudo code .
```

---

# 7. Otimizações

## 7.1 Drivers Adicionais
Configurações → Drivers Adicionais

## 7.2 Energia (TLP)
```bash
sudo apt install tlp tlp-rdw
sudo systemctl enable tlp
```

---

# 8. Checklist Final

- [ ] Atualizar sistema  
- [ ] Instalar restricted-extras  
- [ ] Instalar Kooha  
- [ ] Instalar Virt-Manager  
- [ ] Baixar virtio-win  
- [ ] Ajustar sudo  
- [ ] Configurar permissões  
- [ ] Criar VM corretamente  
- [ ] Instalar drivers na VM  
- [ ] Otimizações opcionais  

---

Fim.
