class ProductList {
    private products: { id: number; name: string; category: string }[] = [];
  
    constructor(initialProducts: { id: number; name: string; category: string }[]) {
      this.products = initialProducts;
    }
  
    /**
     * Método de busca com suporte a múltiplas opções de ordenação.
     * @param query Termo de busca.
     * @param sortOption Opção de ordenação: "asc", "desc", "category", "id".
     * @returns Lista de produtos filtrados e ordenados.
     */
    search(
      query: string,
      sortOption: "asc" | "desc" | "category" | "id" = "asc"
    ): { id: number; name: string; category: string }[] {
      const normalizedQuery = query
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "");
  
      const filteredProducts = this.products.filter((product) =>
        product.name
          .toLowerCase()
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "")
          .includes(normalizedQuery)
      );
  
      // Ordenação com base na opção fornecida
      switch (sortOption) {
        case "desc":
          return filteredProducts.sort((a, b) => b.name.localeCompare(a.name)); // Ordem decrescente por nome
        case "category":
          return filteredProducts.sort((a, b) => a.category.localeCompare(b.category)); // Ordem por categoria
        case "id":
          return filteredProducts.sort((a, b) => a.id - b.id); // Ordem por ID
        case "asc":
        default:
          return filteredProducts.sort((a, b) => a.name.localeCompare(b.name)); // Ordem alfabética ascendente
      }
    }
  
    /**
     * Adiciona um produto à lista.
     * @param product Produto a ser adicionado.
     */
    addProduct(product: { id: number; name: string; category: string }): void {
      this.products.push(product);
    }
  
    /**
     * Lista todos os produtos.
     * @returns Lista completa de produtos.
     */
    listProducts(): { id: number; name: string; category: string }[] {
      return this.products;
    }
  }
  
  // Exemplo de uso
  const productList = new ProductList([
    { id: 1, name: "Lâmpada", category: "Casa" },
    { id: 2, name: "Café", category: "Alimentos" },
    { id: 3, name: "Camisa", category: "Vestuário" },
    { id: 4, name: "Pão", category: "Alimentos" },
    { id: 5, name: "Geladeira", category: "Eletrodomésticos" },
  ]);
  
  console.log("Busca por 'la' (ordem ascendente):");
  console.log(productList.search("la", "asc")); // Busca com ordenação alfabética ascendente
  
  console.log("\nBusca por 'ca' (ordem descendente):");
  console.log(productList.search("ca", "desc")); // Busca com ordenação alfabética descendente
  
  console.log("\nBusca por 'ca' (ordenado por categoria):");
  console.log(productList.search("ca", "category")); // Busca com ordenação por categoria
  
  console.log("\nLista completa antes de adicionar um produto:");
  console.log(productList.listProducts());
  
  // Adicionando um novo produto
  productList.addProduct({ id: 6, name: "Sofá", category: "Casa" });
  
  console.log("\nLista completa após adicionar 'Sofá':");
  console.log(productList.listProducts());
  