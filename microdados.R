# Microdados de óbitos do Estado de São Paulo - 2019
# Microdados de óbitos - 2019
# URL: https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/b7122d17-cffc-42ea-ae1f-579cc4cf4e21/download/microdados_obitos2019.csv


# Carregando a biblioteca necessária
library(readr)
library(dplyr)
library(gridExtra)
library(ggplot2)

# Baixando e lendo os microdados de óbitos
download.file('https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/b7122d17-cffc-42ea-ae1f-579cc4cf4e21/download/microdadosobitos2019.csv',
              'microdadosobitos2019.csv')

# Tabela de códigos dos distritos da capital - SP
download.file('https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/fbcf8362-773d-4cda-90fd-1a216c44f88c/download/tabdist.csv',
              'tabdist.csv')

# Definindo a configuração de locale para o encoding padrão do Windows para sistemas em português
locale <- locale(encoding = "latin1")

# Lendo os arquivos com o encoding correto
microdadosobitos2019 <- read_csv2('microdadosobitos2019.csv', col_names = TRUE, locale = locale)
tabdist <- read_csv2('tabdist.csv', col_names = TRUE, locale = locale)

# Aqui realiza análises específicas com base nos dados dos óbitos
# objetivo analisar a distribuição de óbitos por idade, sexo, localização, etc.

# Plotando o histograma da distribuição de óbitos por idade
# Verificando e corrigindo valores de idade improváveis
idade_maxima <- 100

# Convertendo a coluna de idade para o tipo numérico
microdadosobitos2019$idadeanos[microdadosobitos2019$idadeanos > idade_maxima] <- NA

# Plotando o histograma da distribuição de óbitos por idade
histograma_idade <- ggplot(data = microdadosobitos2019, aes(x = idadeanos)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribuição de Óbitos por Idade",
       x = "Idade",
       y = "Número de Óbitos")

# Filtrar os dados para incluir apenas "M" (masculino) e "F" (feminino)
microdados_sexo_filtrado <- microdadosobitos2019 %>%
  filter(sexo %in% c("M", "F"))

# Criar um gráfico de barras para distribuição de sexo
grafico_sexo <- ggplot(data = microdadosobitos2019, aes(x = sexo, fill = sexo)) +
  geom_bar() +
  scale_fill_manual(values = c("M" = "blue", "F" = "pink")) +
  labs(title = "Distribuição de Óbitos por Sexo",
       x = "Sexo",
       y = "Número de Óbitos")

# Mapear os códigos de raça/cor para os rótulos correspondentes
microdadosobitos2019$racacor <- factor(microdadosobitos2019$racacor,
                                       levels = c(1, 2, 3, 4),
                                       labels = c("Branco", "Negro", "Pardo", "Indígena"))

# Criar um gráfico de barras para distribuição de raça/cor
grafico_raca_cor <- ggplot(data = microdadosobitos2019, aes(x = racacor)) +
  scale_fill_viridis(discrete = TRUE) +  # Usando a paleta de cores viridis
  geom_bar(fill = "salmon") +
  labs(title = "Distribuição de Óbitos por Raça/Cor",
       x = "Raça/Cor",
       y = "Número de Óbitos")


# Este código irá criar um gráfico de barras mostrando o número de mortes por distrito, com os distritos ordenados 
# pelo número de mortes. Isso proporciona uma visualização clara da distribuição de óbitos por distrito
# Relacionando as tabelas pelo código do município

# Agrupando os dados por distrito e contando o número de mortes em cada um
mortes_por_distrito <- microdadosobitos2019 %>%
  group_by(coddistres) %>%
  summarise(numero_de_mortes = n()) %>%
  top_n(10, numero_de_mortes)  # Selecionando os 10 distritos com mais mortes

# Adicionando os nomes dos distritos
mortes_por_distrito <- inner_join(mortes_por_distrito, tabdist, by = c("coddistres" = "cod_distrito"))

# Calculando as porcentagens de mortes por distrito
mortes_por_distrito <- mortes_por_distrito %>%
  mutate(percentual = numero_de_mortes / sum(numero_de_mortes) * 100)

# Reordenando os níveis do fator nome_distrito de acordo com o número de mortes
mortes_por_distrito$nome_distrito <- factor(mortes_por_distrito$nome_distrito, 
                                            levels = mortes_por_distrito$nome_distrito[order(-mortes_por_distrito$numero_de_mortes)])

# Criando o gráfico de pizza com a paleta de cores viridis
gg_pizza <- ggplot(mortes_por_distrito, aes(x = "", y = numero_de_mortes, fill = nome_distrito)) +
  geom_bar(stat = "identity", width = 1) +
  geom_text(aes(label = paste0(round(percentual, 1), "%")), position = position_stack(vjust = 0.5)) +
  coord_polar("y", start = 0) +
  labs(title = "Número de Mortes nos 10 Principais Distritos",
       fill = "Distrito") +
  theme_void() +
  theme(legend.position = "right")

# Criando o painel com os gráficos
painel <- grid.arrange(histograma_idade, grafico_sexo, grafico_raca_cor, gg_pizza, ncol = 2)

# Exibir o painel
print(painel)

# Filtrando os dados para o distrito de Sapopemba
mortes_sapopemba <- microdadosobitos2019 %>%
  filter(coddistres == 76)

# Criando um gráfico de barras para o número de mortes por raça/cor em Sapopemba
grafico_raca_cor_sapopemba <- ggplot(data = mortes_sapopemba, aes(x = racacor)) +
  scale_fill_viridis(discrete = TRUE) +  # Usando a paleta de cores viridis
  geom_bar(fill = "salmon") +
  labs(title = "Distribuição de Óbitos por Raça/Cor em Sapopemba",
       x = "Raça/Cor",
       y = "Número de Óbitos")

# Plotando o histograma da distribuição de óbitos por idade em Sapopemba
histograma_idade_sapopemba <- ggplot(data = mortes_sapopemba, aes(x = idadeanos)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribuição de Óbitos por Idade em Sapopemba",
       x = "Idade",
       y = "Número de Óbitos")

# Exibindo os gráficos
grid.arrange(grafico_raca_cor_sapopemba, histograma_idade_sapopemba, ncol = 2)

