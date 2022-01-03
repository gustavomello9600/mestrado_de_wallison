library(tidyverse)
library(readxl)
library(ScottKnott)
library(openxlsx)

#Filtra as abas que contém os dados de interesse
nomes_das_abas <- excel_sheets("Entradas/pH/pH_Sequivaris_IIa24_e_IIA53.xls")
nomes_das_abas_de_interesse <- nomes_das_abas[-(1:4)]

#Cria uma tabela vazia para futura inserção de dados
dados <- as_tibble(data.frame(Sequivar=character(),
                              Isolado=character(),
                              Repeticao=character(),
                              pH=double(),
                              Crescimento=double()))

#Povoa a tabela de dados
for (isolado in nomes_das_abas_de_interesse) {
  #Nomeia a sequivar
  if (startsWith(isolado, "CCR")) {
    sequivar <- "IIA-24"
  } else {
    sequivar <- "IIA-53"
  }
  
  dados_do_isolado <- read_excel("Entradas/pH/pH_Sequivaris_IIa24_e_IIA53.xls",
                                 isolado,
                                 "A1:I15")
  
  dados_do_isolado_formatados <- dados_do_isolado %>%
    pivot_longer(
      cols = starts_with("R"),
      names_to = "Repeticao",
      names_prefix = "R",
      values_to = "Crescimento",
      values_drop_na = TRUE
    ) %>%
    add_column(Sequivar=sequivar, .before = "Ph") %>%
    add_column(Isolado=isolado, .before = "Ph") %>%
    rename(pH=Ph)
  
  #Adiciona os novos dados do isolado na tabela
  dados <- dados %>% bind_rows(dados_do_isolado_formatados)
}

dados <- dados %>%
  mutate_if(is.character, as.factor) %>%
  mutate(pH=as.factor(pH))

#Salva a tabela em formato excel
write.xlsx(dados, "Saídas/crescimento_por_ph.xlsx", sheetName="Dados")

#Inserir aqui as funções de análise ScottKnott

#---------------------------------------------

