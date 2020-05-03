library(tidyverse)
library(openxlsx)
library(lubridate)
library(imputeTS)
library(httr)
library(ggforce)

z = readRDS("datos.RDS")

z %>%
  select(1:5) %>%
  head(5) %>%
  {knitr::kable(., caption = "Data medida en cada punto:")}

nombres = readRDS("nombres.RDS")
nombres %>% 
  sample_n(5) %>%
  {knitr::kable(., caption = "Organización en Departamentos:")}

plotear =  z %>%
  mutate_if(is.character,as.double) %>%
  mutate(Fecha = (PUNTO.DE.MEDICIÓN - minutes(30))) %>%
  select(-PUNTO.DE.MEDICIÓN) %>%
  mutate(Fecha2 = if_else(Fecha > dmy("15-03-2020"),"DC","AC")) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),abs) %>%
  group_by(Fecha2) %>%
  ungroup() %>%
  pivot_longer(-c(Fecha,Fecha2),names_to = "PUNTO.DE.MEDICIÓN", values_to = "gwh") %>%
  left_join(nombres) 

plotear %>% filter(DEPARTAMENTO=="TUMBES") %>%  left_join(nombres) %>%  select(1,3,4) %>% pivot_wider(names_from = `PUNTO.DE.MEDICIÓN`,values_from = gwh) %>%  mutate(suma = .[[2]] + .[[3]] + .[[4]] + .[[5]] + .[[6]]) %>%  rename( `PUNTO.DE.MEDICIÓN` = Fecha) %>% 
  slice(1:5) %>% 
  {rbind(names %>%  select(PUNTO.DE.MEDICIÓN,`21588`,`21585`,`21586`,`21589`,`21590`,`21614`) %>%  mutate(suma = NA),.)} %>%
  {knitr::kable(., caption = "Demanda - Tumbes")}

plotear %>% 
  filter(DEPARTAMENTO=="TUMBES") %>%
  mutate(PUNTO.DE.MEDICIÓN = `FECHA.HORA./.SUBESTACIÓN`) %>%
  ggplot(aes(x=Fecha,y=gwh)) +
  geom_line() +
  facet_wrap(scales = "free",.~ PUNTO.DE.MEDICIÓN,labeller = labeller(PUNTO.DE.MEDICIÓN = label_wrap_gen(22))) 


limite <- function(x) ifelse(x > 300,NA,x)
scale2 <- function(x) ifelse(x > (median(x,na.rm = TRUE) + (4 * sd(x,na.rm = TRUE))),NA,x)

ploteo2 = z %>%
  mutate_if(is.character,as.double) %>%
  mutate(Fecha = (PUNTO.DE.MEDICIÓN - minutes(30))) %>%
  select(-PUNTO.DE.MEDICIÓN) %>%
  mutate(Fecha2 = if_else(Fecha > dmy("15-03-2020"),"DC","AC")) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),limite) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),abs) %>%
  group_by(Fecha2) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),scale2) %>%
  {.[, which(colMeans(!is.na(.)) > 0.5)]} %>%
  ungroup() %>%
  mutate_at(vars(-c(Fecha,Fecha2)),na_ma,maxgap=47) %>%
  pivot_longer(-c(Fecha,Fecha2),names_to = "PUNTO.DE.MEDICIÓN", values_to = "gwh") %>%
  left_join(nombres)

ploteo2 %>% 
  filter(DEPARTAMENTO=="TUMBES") %>%
  group_by(PUNTO.DE.MEDICIÓN) %>%
  mutate(test = is.na(gwh)) %>%
  mutate(gwh = na_seasplit(gwh,find_frequency = TRUE)) %>%
  ungroup() %>%
  mutate(PUNTO.DE.MEDICIÓN = `FECHA.HORA./.SUBESTACIÓN`) %>%
  ggplot(aes(x=Fecha,y=gwh)) +
  geom_line(aes(color=test),show.legend = FALSE) +
  facet_wrap(scales = "free",.~ PUNTO.DE.MEDICIÓN,labeller = labeller(PUNTO.DE.MEDICIÓN = label_wrap_gen(22))) +
  scale_color_hue(l=40)

plotear %>% 
  filter(DEPARTAMENTO=="LAMBAYEQUE") %>%
  group_by(PUNTO.DE.MEDICIÓN) %>%
  mutate(gwh = na_ma(gwh)) %>%
  ungroup() %>%
  mutate(PUNTO.DE.MEDICIÓN = `FECHA.HORA./.SUBESTACIÓN`) %>%
  ggplot(aes(x=Fecha,y=gwh)) +
  geom_line() +
  facet_wrap(scales = "free",.~ PUNTO.DE.MEDICIÓN,labeller = labeller(PUNTO.DE.MEDICIÓN = label_wrap_gen(22))) +
  scale_x_datetime(date_breaks = "23 days",date_labels = "%d-%b") +
  ggforce::geom_mark_ellipse(aes(filter=gwh > 300),fill="red")

ploteo2 %>% 
  filter(DEPARTAMENTO=="LAMBAYEQUE") %>%
  group_by(PUNTO.DE.MEDICIÓN) %>%
  mutate(gwh = na_ma(gwh)) %>%
  ungroup() %>%
  mutate(PUNTO.DE.MEDICIÓN = `FECHA.HORA./.SUBESTACIÓN`) %>%
  ggplot(aes(x=Fecha,y=gwh)) +
  geom_line() +
  facet_wrap(scales = "free",.~ PUNTO.DE.MEDICIÓN,labeller = labeller(PUNTO.DE.MEDICIÓN = label_wrap_gen(22))) +
  scale_x_datetime(date_breaks = "23 days",date_labels = "%d-%b") +
  ggforce::geom_mark_ellipse(aes(filter=gwh > 30),fill="red")

cont = z %>%
  mutate_if(is.character,as.double) %>%
  mutate(Fecha = as_date(PUNTO.DE.MEDICIÓN - minutes(30))) %>%
  select(-PUNTO.DE.MEDICIÓN) %>%
  mutate(Fecha2 = if_else(Fecha > dmy("15-03-2020"),"DC","AC")) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),limite) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),abs) %>%
  group_by(Fecha2) %>%
  mutate_at(vars(-c(Fecha,Fecha2)),scale2) %>%
  ungroup() %>%
  mutate_at(vars(-c(Fecha,Fecha2)),na_ma,maxgap=47) 

pordepa= cont %>%
  {.[, which(colMeans(!is.na(.)) > 0.5)]} %>%
  {.[, which(colMeans(.!= 0,na.rm = TRUE) > 0.5)]} %>%
  group_by(Fecha2) %>% 
  mutate_at(vars(-c(Fecha,Fecha2)), na_seasplit,algorithm="ma") %>% 
  ungroup() %>% 
  mutate_at(vars(-c(Fecha,Fecha2)), funs(. / 2000)) %>%
  pivot_longer(-c(Fecha,Fecha2),names_to = "PUNTO.DE.MEDICIÓN",values_to = "gwh") %>%
  left_join(nombres) %>%
  group_by(Fecha,DEPARTAMENTO) %>%
  summarise(gwh = sum(gwh)) %>%
  ungroup()

factorizar = pordepa %>%
  filter(Fecha < as_date("2020-03-15")) %>%
  group_by(DEPARTAMENTO) %>%
  summarise(gwh = sum(gwh)) %>%
  arrange(gwh) %>%
  select(DEPARTAMENTO)%>%
  tail(7) %>%
  {rbind(c("OTROS"),.)}

nombres = mutate(nombres,DEPARTAMENTO = ifelse(nombres$DEPARTAMENTO %in% factorizar[[1]],DEPARTAMENTO,"OTROS"))

cont %>%
  {.[, which(colMeans(!is.na(.)) > 0.5)]} %>%
  # {.[, which(colMeans(.!= 0,na.rm = TRUE) > 0.5)]} %>%
  group_by(Fecha2) %>% 
  ungroup() %>% 
  mutate_at(vars(-c(Fecha,Fecha2)), funs(. / 2000)) %>%
  pivot_longer(-c(Fecha,Fecha2),names_to = "PUNTO.DE.MEDICIÓN",values_to = "gwh") %>%
  left_join(nombres) %>%
  group_by(Fecha,DEPARTAMENTO) %>%
  summarise(gwh = sum(gwh)) %>%
  ungroup() %>%
  group_by(DEPARTAMENTO) %>%
  mutate(gwh = na_seasplit(gwh,find_frequency = TRUE)) %>% 
  ungroup() %>%
  ggplot(aes(x=Fecha, y =gwh)) +
  # geom_area(aes(fill = factor(DEPARTAMENTO,levels = factorizar[[1]]))color="black",position = "stack") +
  geom_line() +
  facet_wrap(.~factor(DEPARTAMENTO,levels = rev(factorizar[[1]])),scales = "free_y") +
  scale_x_date(date_breaks = "1 weeks",date_labels = "%d-%b",expand = c(0,0)) +
  geom_vline(xintercept = as_date("2020-03-15"),size=1.5,linetype="dashed") +
  labs(title = "Consumo Eléctrico - Empresas Distribuidoras",subtitle = "Consumo eléctrico medido en estaciones de propiedad de empresas distribuidoras.",
       y = element_blank(),x=element_blank(),fill="Departamento", caption = "Fuente: COES. Autor: Luis José Zapata Bobadilla.") +
  theme_gray()+
  theme(axis.text.x.bottom = element_text(angle = 90,hjust=0.7)) +
  ggforce::geom_mark_ellipse(aes(filter=(gwh > 4)&(DEPARTAMENTO=="LAMBAYEQUE")),fill="red")

cont %>%
  {.[, which(colMeans(!is.na(.)) > 0.5)]} %>%
  {.[, which(colMeans(.!= 0,na.rm = TRUE) > 0.5)]} %>%
  group_by(Fecha2) %>% 
  ungroup() %>% 
  mutate_at(vars(-c(Fecha,Fecha2)), funs(. / 2000)) %>%
  pivot_longer(-c(Fecha,Fecha2),names_to = "PUNTO.DE.MEDICIÓN",values_to = "gwh") %>%
  left_join(nombres) %>%
  group_by(Fecha,DEPARTAMENTO) %>%
  summarise(gwh = sum(gwh)) %>%
  ungroup() %>%
  group_by(DEPARTAMENTO) %>%
  mutate(gwh = na_seasplit(gwh,find_frequency = TRUE)) %>% 
  ungroup() %>%
  ggplot(aes(x=Fecha, y =gwh)) +
  geom_area(aes(fill=factor(DEPARTAMENTO,levels = (factorizar[[1]]))),color="black") +
  scale_x_date(date_breaks = "1 weeks",date_labels = "%d-%b",expand = c(0,0)) +
  geom_vline(xintercept = as_date("2020-03-15"),size=1.5,linetype="dashed") +
  labs(title = "Consumo Eléctrico - Empresas Distribuidoras",subtitle = "Consumo eléctrico medido en estaciones de propiedad de empresas distribuidoras.",
       y = element_blank(),x=element_blank(),fill="Departamento", caption = "Fuente: COES. Autor: Luis José Zapata Bobadilla.") +
  theme_gray() +
  theme(axis.text.x.bottom = element_text(angle = 90,hjust=0.7))

