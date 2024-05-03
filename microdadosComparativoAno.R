# Carregando as bibliotecas necessárias
library(readr)
library(dplyr)
library(ggplot2)
library(gridExtra)

# Função para ler os dados de óbitos de acordo com o ano selecionado
ler_dados_obitos <- function(ano) {
  link <- switch(ano,
                 "2019" = "https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/b7122d17-cffc-42ea-ae1f-579cc4cf4e21/download/microdados_obitos2019.csv",
                 "2020" = "https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/14f1b326-3366-489d-a727-5a4956baf31b/download/microdados_obitos2020.csv",
                 "2021" = "https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/a2b2c4cd-72c7-4f2a-b3f6-441e76077a9e/download/microdados_obitos2021.csv")
  
  filename <- paste0("microdadosobitos", ano, ".csv")
  download.file(link, filename, mode = "wb")
  read_csv2(filename, col_names = TRUE)
}

# Lendo os dados de óbitos de 2019
dados_2019 <- ler_dados_obitos("2019")
# Lendo os dados de óbitos de 2020
dados_2020 <- ler_dados_obitos("2020")
# Lendo os dados de óbitos de 2021
dados_2021 <- ler_dados_obitos("2021")

# Plotando o histograma da distribuição de óbitos por idade para 2019
histograma_idade_2019 <- ggplot(data = dados_2019, aes(x = idadeanos)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribuição de Óbitos por Idade (2019)",
       x = "Idade",
       y = "Número de Óbitos")

# Plotando o histograma da distribuição de óbitos por idade para 2020
histograma_idade_2020 <- ggplot(data = dados_2020, aes(x = idadeanos)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribuição de Óbitos por Idade (2020)",
       x = "Idade",
       y = "Número de Óbitos")

# Plotando o histograma da distribuição de óbitos por idade para 2021
histograma_idade_2021 <- ggplot(data = dados_2021, aes(x = idadeanos)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribuição de Óbitos por Idade (2021)",
       x = "Idade",
       y = "Número de Óbitos")

# Exibindo os histogramas de idade
grid.arrange(histograma_idade_2019, histograma_idade_2020, histograma_idade_2021, ncol = 3)

# Plotando o gráfico de linha comparativo de mortes ano a ano
dados_anuais <- bind_rows(
  data.frame(Ano = 2019, Mortes = nrow(dados_2019)),
  data.frame(Ano = 2020, Mortes = nrow(dados_2020)),
  data.frame(Ano = 2021, Mortes = nrow(dados_2021))
)

grafico_linha_comparativo <- ggplot(dados_anuais, aes(x = Ano, y = Mortes, group = 1)) +
  geom_line(color = "blue") +
  geom_point(color = "blue", size = 3) +
  labs(title = "Comparativo de Mortes por Ano",
       x = "Ano",
       y = "Número de Óbitos")

print(grafico_linha_comparativo)
