library(tidyverse)
library(magrittr)
library(rvest)
library(xml2)
library(lubridate)

page <- read_html("https://en.wikipedia.org/wiki/List_of_popes")

xml_find_all(page, ".//br") %>% xml_add_sibling("p", " ")
xml_find_all(page, ".//br") %>% xml_remove()

df <- tibble(number = NULL, name_all = NULL, birth = NULL, start = NULL, end = NULL)

for (i in 1:21) {
  
  df_i <- page %>% 
    html_elements("table") %>% 
    magrittr::extract2(i) %>% 
    html_table() %>% 
    filter(`Pontiff number` != "—" & `Pontiff number` != "" & `Name: English · Latin` != "Interregnum") %>% 
    mutate(number = `Pontiff number` %>% 
             as.numeric(),
           name_all = `Name: English · Latin`,
           start1 = Pontificate %>% 
             str_extract("\\d*\\s*\\w+\\s\\d+"),
           end1 = Pontificate %>% 
             str_extract("\\–\\s(\\d*\\s*\\w+\\s\\d+)") %>%
             str_replace("–\\s", ""),
           birth1 = `Date and Place of birth` %>% 
             str_extract("\\d{1,2}\\s\\w+\\s\\d+"),
           birth2 = `Date and Place of birth` %>% 
             str_extract("\\d+[\\–\\/]*\\d*\\s+")) %>% 
    select(number, name_all, birth1, birth2, start1, end1)
  
  df <- df %>% 
    bind_rows(df_i)
  
  rm(df_i)
}

df <- df %>% 
  mutate(canonization = case_when(str_detect(name_all, "Servant of God") ~ "Servant of God",
                                  str_detect(name_all, "Ven.") ~ "Venerable",
                                  str_detect(name_all, "Bl.") ~ "Blessed",
                                  str_detect(name_all, "St") ~ "Saint"),
         name_full = case_when(str_detect(name_all, "Servant of God") ~ str_replace(name_all, "Servant of God ", ""),
                               str_detect(name_all, "Ven.") ~ str_replace(name_all, "Ven. ", ""),
                               str_detect(name_all, "Bl.") ~ str_replace(name_all, "Bl. ", ""),
                               str_detect(name_all, "St") ~ str_replace(name_all, "St ", ""),
                               TRUE ~ name_all),
         name_full = name_full %>% 
           str_extract("([A-Z]{1}[a-z]+)+(\\s[A-Z]{1}[a-z]+)*(\\s[IVX]+\\b)?"),
         name = name_full %>% 
           str_extract("([A-Z]{1}[a-z]+)+(\\s[A-Z]{1}[a-z]+)*"),
         suffix = name_full %>% 
           str_replace("([A-Z]{1}[a-z]+\\s*)+([A-Z]{1}[a-z]+\\s)*", "") %>% 
           as.roman() %>% 
           as.numeric(),
         start1 = case_when(str_detect(start1, "\\d+\\s+\\w+\\s+\\d+") ~ start1,
                            TRUE ~ paste0("1 ", start1)), 
         end1 = case_when(str_detect(end1, "\\d+\\s+\\w+\\s+\\d+") ~ end1,
                          TRUE ~ paste0("1 ", end1)), 
         start = start1 %>% 
           lubridate::parse_date_time("d m Y"),
         end = end1 %>% 
           lubridate::parse_date_time("d m Y"),
         birth2 = case_when(is.na(birth1) ~ paste0("30 June ", birth2) %>% 
                              str_replace("[\\–\\/]\\d{1,2}", "")),
         birth = case_when(is.na(birth1) ~ lubridate::parse_date_time(birth2, "d m Y"),
                           is.na(birth2) ~ lubridate::parse_date_time(birth1, "d m Y"))) %>% 
  replace_na(list(suffix = 1)) %>% 
  select(number, name_full, name, suffix, canonization, birth, start, end)

# Manual

df$start[df$number == 1] <- lubridate::parse_date_time("1 January 0030", "d m Y")
df$end[df$number == 1] <- lubridate::parse_date_time("31 December 0064", "d m Y")

df$start[df$number == 2] <- lubridate::parse_date_time("1 January 0064", "d m Y")
df$end[df$number == 2] <- lubridate::parse_date_time("31 December 0076", "d m Y")

df$start[df$number == 3] <- lubridate::parse_date_time("1 January 0076", "d m Y")
df$end[df$number == 3] <- lubridate::parse_date_time("31 December 0088", "d m Y")

popes <- df %>% 
  mutate(age_start = lubridate::interval(birth, start) %/% lubridate::years(1),
         age_end = lubridate::interval(birth, end) %/% lubridate::years(1),
         tenure = lubridate::interval(start, end) / lubridate::years(1))

write_csv(popes, "popes.csv")