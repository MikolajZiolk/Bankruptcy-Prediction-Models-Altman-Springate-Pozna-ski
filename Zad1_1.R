library(readxl)
library(distr)
library(dplyr)
library(ggplot2)
library(tidyr)



dane <- read_excel("C:/Users/mikol/OneDrive/Desktop/Modelowanie Ryzyka KiU//zad1/dane.xlsx")

sum(is.na(dane)) #89 wart null

dane <- dane |> #Zamiana na wartosci numeryczne
  mutate(across(where(is.character), ~as.numeric(.)))

dane <- dane |> #zamiana null na wartosci srednie według kolumn
  mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))

sum(is.na(dane)) # brak wartości null



# Model Altmana -----------------------------------------------------------


#wybor 100 firm które upadły i 100 które przetrwały
#zmienna x65 0-upadła, 1-przetrwała

set.seed(123)

firmy_upadle <- dane |> 
  filter(x65 == 0) |>  sample_n(100)

firmy_przetrwaly <- dane |> 
  filter(x65 == 1) |>  sample_n(100)

dane_wybrane <- bind_rows(firmy_upadle, firmy_przetrwaly)

#model Altmana do predykcji upadłości 
#x1/x2/x3/x4/x5
#x40/x6/x7/x8/x9

dane_wybraneALtman <- dane_wybrane |> 
  mutate(Z = 1.2 * x40 + 1.4 * x6 + 3.3 * x7 + 0.6 * x8 + 0.99 * x9)

dane_wybraneALtman <- dane_wybraneALtman |> 
  mutate(predykcja = case_when(
    Z > 3.0 ~ 1,   # Firma powinna przetrwać
    Z < 1.8 ~ 0,   # bankructwo
    TRUE ~ NA_real_  # Strefa szara - niepewność
  ))

dane_wybraneALtman$predykcja

# oszacowanie modelu

# Odsetek poprawnych oszacowań (dokładność modelu)
dokladnosc <- mean(dane_wybraneALtman$predykcja == dane_wybraneALtman$x65, na.rm = TRUE)
print(paste("Dokładność modelu Altmana:", round(dokladnosc * 100, 2), "%"))


# Błąd I rodzaju: model przewidział przetrwanie, ale firma upadła
blad_I_rodzaju <- sum(dane_wybraneALtman$predykcja == 1 & dane_wybraneALtman$x65 == 0, na.rm = TRUE) /
  sum(dane_wybraneALtman$x65 == 0)
print(paste("Błąd I rodzaju:", round(blad_I_rodzaju * 100, 2), "%"))

# Błąd II rodzaju: model przewidział upadłość, ale firma przetrwała
blad_II_rodzaju <- sum(dane_wybraneALtman$predykcja == 0 & dane_wybraneALtman$x65 == 1, na.rm = TRUE) /
  sum(dane_wybraneALtman$x65 == 1)
print(paste("Błąd II rodzaju:", round(blad_II_rodzaju * 100, 2), "%"))


# Model Springate’a -------------------------------------------------------

# X1 = x3 (working capital / total assets)
# X2 = x7 (EBIT / total assets)
# X3 = x12 (gross profit / short-term liabilities)
# X4 = x9 (sales / total assets)
#działamy na tych samym zbiorze(100firm upadłych i 100przetrwałych) jak w modelu altmana

dane_wybraneSpr <- dane_wybrane |> 
  mutate(Z_springate = 1.03 * x3 + 3.07 * x7 + 0.66 * x12 + 0.4 * x9)

# Próg graniczny w modelu to 0.862, gdy Z>0.862 firma nie jest zagrożona upadłością
# Z > 0.862 -> firma przetrwa
# Z <= 0.862 -> upadłość

dane_wybraneSpr <- dane_wybraneSpr |> 
  mutate(pred_springate = ifelse(Z_springate > 0.862, 1, 0))

#ocena skutecznosci modelu

# Dokładność 
dokladnosc_springate <- mean(dane_wybraneSpr$pred_springate == dane_wybraneSpr$x65, na.rm = TRUE)
print(paste("Dokładność modelu Springate’a:", round(dokladnosc_springate * 100, 2), "%"))

# Błąd I rodzaju: przewidziano przetrwanie (1), ale firma upadła (x65 == 0)
blad_I_rodzaju_springate <- sum(dane_wybraneSpr$pred_springate == 1 & dane_wybraneSpr$x65 == 0, na.rm = TRUE) /
  sum(dane_wybraneSpr$x65 == 0)
print(paste("Błąd I rodzaju (Springate):", round(blad_I_rodzaju_springate * 100, 2), "%"))

# Błąd II rodzaju: przewidziano upadłość (0), ale firma przetrwała (x65 == 1)
blad_II_rodzaju_springate <- sum(dane_wybraneSpr$pred_springate == 0 & dane_wybraneSpr$x65 == 1, na.rm = TRUE) /
  sum(dane_wybraneSpr$x65 == 1)
print(paste("Błąd II rodzaju (Springate):", round(blad_II_rodzaju_springate * 100, 2), "%"))


# Model Poznański ---------------------------------------------------------
# X1 = x1 (net profit / total assets)
# X2 = x46 [(current assets - inventory) / short-term liabilities]
# X3 = udział kapitału stałego: X10 (equity / total assets) + (1 / X17) (czyli odwrotność total assets / total liabilities)
# X4 = x19 (gross profit / sales)

#obliczamy x3(brak informacji o kapitałach obcych, tworzymy jedynie przybliżenie)
dane_wybranePoz <- dane_wybrane |> 
  mutate(
    X3_poznan = x10 + (1 / x17),
    Z_poznan = 3.562 * x1 + 1.58 * x46 + 4.288 * X3_poznan + 6.719 * x19 - 2.368,
    pred_poznan = ifelse(Z_poznan > 0, 1, 0)
  )

# Dokładność modelu
dokladnosc_poznan <- mean(dane_wybranePoz$pred_poznan == dane_wybranePoz$x65, na.rm = TRUE)
print(paste("Dokładność modelu Poznańskiego:", round(dokladnosc_poznan * 100, 2), "%"))

# Błąd I rodzaju
blad_I_rodzaju_poznan <- sum(dane_wybranePoz$pred_poznan == 1 & dane_wybranePoz$x65 == 0, na.rm = TRUE) /
  sum(dane_wybranePoz$x65 == 0)
print(paste("Błąd I rodzaju (Poznański):", round(blad_I_rodzaju_poznan * 100, 2), "%"))

# Błąd II rodzaju
blad_II_rodzaju_poznan <- sum(dane_wybranePoz$pred_poznan == 0 & dane_wybranePoz$x65 == 1, na.rm = TRUE) /
  sum(dane_wybranePoz$x65 == 1)
print(paste("Błąd II rodzaju (Poznański):", round(blad_II_rodzaju_poznan * 100, 2), "%"))


# tabela ------------------------------------------------------------------

# Tabela porównawcza skuteczności
porownanie_modeli <- tibble(
  Model = c("Altman", "Springate", "Poznański"),
  Dokładność = c(dokladnosc, dokladnosc_springate, dokladnosc_poznan),
  Blad_I_rodzaju = c(blad_I_rodzaju, blad_I_rodzaju_springate, blad_I_rodzaju_poznan),
  Blad_II_rodzaju = c(blad_II_rodzaju, blad_II_rodzaju_springate, blad_II_rodzaju_poznan)
)

print(porownanie_modeli)

# Dane do wykresu – pivot_longer
dane_wykres <- porownanie_modeli |> 
  pivot_longer(cols = -Model, names_to = "Metryka", values_to = "Wartość")

# Wykres
ggplot(dane_wykres, aes(x = Model, y = Wartość * 100, fill = Metryka)) +
  geom_col(position = "dodge") +
  labs(title = "Porównanie modeli predykcji upadłości",
       y = "Wartość (%)",
       x = "Model",
       fill = "Metryka") +
  scale_fill_manual(values = c("Dokładność" = "forestgreen",
                               "Blad_I_rodzaju" = "firebrick",
                               "Blad_II_rodzaju" = "darkorange")) +
  theme_minimal()



# LDA - własny model ------------------------------------------------------
library(MASS)

# wybieramy tylko potrzebne kolumny
dane_lda <- dane_wybrane

model_lda <- lda(x65 ~ x40 + x6 + x7 + x8 + x9, data = dane_lda)

summary(model_lda)
model_lda

# Predykcja klas
pred_lda <- predict(model_lda)

# Dodajemy do danych
dane_lda$predykcja_lda <- as.numeric(pred_lda$class)

# Skuteczność (dokładność)
dokladnosc_lda <- mean(dane_lda$predykcja_lda == dane_lda$x65)
print(paste("Dokładność modelu LDA:", round(dokladnosc_lda * 100, 2), "%"))

model_lda$scaling #wagi wpspółzmiennych


ggplot(dane_lda, aes(x = pred_lda$x[,1], fill = as.factor(x65))) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
  labs(title = "Rozkład wartości dyskryminacyjnej LDA",
       x = "Wynik funkcji dyskryminacyjnej", fill = "Status (x65)") +
  theme_minimal()


#Na podstawie zmiennych wykorzystywanych w modelu Altmana zbudowano własny model oceny ryzyka upadłości firm przy użyciu liniowej analizy dyskryminacyjnej (LDA). Uzyskany model cechuje się współczynnikami znacznie różniącymi się od klasycznego modelu Altmana. Przykładowo, największe znaczenie (ujemne) ma zmienna x7 (EBIT / aktywa), co sugeruje, że w polskich danych nawet wysokie zyski operacyjne mogą nie gwarantować przetrwania firmy.
#Niestety, skuteczność modelu LDA okazała się bardzo niska (13%), co oznacza, że przyjęte zmienne nie zapewniają dobrej separacji firm upadających i przetrwałych. Sugeruje to konieczność weryfikacji doboru zmiennych, jakości danych oraz ewentualnego użycia innych metod klasyfikacyjnych.


