library(shiny)
library(dplyr)
library(ggplot2)
library(readr)

# minimalna ilosc glosow, od jakiej analizujemy filmy
min_votes <- 1000


# pobieramy dane o filmach, osobach i kto gdzie
#filmy <- read.csv("data/movies_sort.csv")
#osoby <- read.csv("data/persons_por.csv")
# konwersja znakow
#osoby$personName <- iconv(osoby$personName, "UTF-8", "WINDOWS-1250")
#osoby_w_filmach <- read.csv("data/all_personinmovies_por.csv")

# przypisz filmy do osoby - w osoby_w_filmach dodac rok filmy, ocene tytul?
#filmy_z_osobami <- left_join(filmy, osoby_w_filmach, by = "filmID")
#filmy_z_osobami <- select(filter(filmy_z_osobami, personID != "NA"), filmID, personID, roleID, title, year, rate, votes)

# dane obrobione i spakowane
load("data/film_data.RData")

# tutaj juz funkcja
tablica_osoby <- function(osobaName, rola) {
	# funkcja zwraca tablic? z filmami dla wskazanej osoby we wskazanej roli (funkcji)
	#1;rezyser
	#2;scenarzysta
	#3;muzyka
	#4;zdjecia
	#6;aktor
	
	#przefiltruj tabel? z filmami po roli i minimalnej ilo?ci oddanych g?os?w
	filmy_z_osoba <- filter(filmy_z_osobami, roleID == rola & votes >= min_votes)
	
	# szukamy osoby
	szukana_osoba_ID <- osoby[which(osoby$personName == osobaName), ]$personID[1]
	# ta jedynka na ko?cu daje pierwszy wynik, jakby by?o wi?cej takich os?b - np. David Lynch jest nie jeden....
	
	# szukamy filmow z ta osoba
	filmy_z_osoba <- select(filter(filmy_z_osoba, personID == szukana_osoba_ID), filmID, title, year, rate, votes)
	# najpierw te nalepsze
	filmy_z_osoba <- filmy_z_osoba[order(filmy_z_osoba$rate, decreasing = TRUE),]	
	
	return(filmy_z_osoba)
}

# poczatek urla dla podgladu filmow
filename_base <- "http://prokulski.net/filmweb/tests/filminfo.php?id="



shinyServer(function(input, output, session) {

	get_page <- reactive({
		input$goFilmButton
		input$goButton
		
		tab <- isolate(select(tablica_osoby(input$filmosoba, input$filmrola), title, year, rate, filmID))

		# budujemy url do strony z info o filmie
		filmnum <- isolate(tab[which(tab$title == input$filmidnum),]$filmID)
		url_path <- isolate(paste(filename_base, filmnum, sep = ""))
		return(url_path)
	})
	

	output$tabela <- renderTable({
		input$goButton
		
		tab <- isolate(select(tablica_osoby(input$filmosoba, input$filmrola), title, year, rate, filmID))

		names(tab) <- isolate(c("Tytul filmu", "Rok produkcji", "Ocena", "ID filmu"))
		isolate(tab)
	},
	include.rownames = FALSE)
	

	output$previewpage <- renderText({
		# wczytujemy HTMLa z podgladem info o filmie
		input$goFilmButton
		input$goButton
		
		isolate(read_file(get_page()))
	})
	
	output$wykres <- renderPlot({
		input$goButton
		
		tab <- isolate(tablica_osoby(input$filmosoba, input$filmrola))

		p <- isolate(ggplot(tab, aes(year, rate)) +
			theme_bw() +
			xlab("Rok") +
			ylab("Ocena") +
			geom_point() +
			geom_text(aes(label=title), vjust=0, hjust=0) +
			theme(plot.title = element_text(size = 18),
					axis.text.x = element_text(size = 7),
					axis.text.y = element_text(size = 7),
					panel.grid.minor = element_blank()) +
			scale_x_continuous(breaks = seq(1880, 2020, by = 5)) +
			scale_y_continuous(breaks = seq(0, 10, by = 0.5)) +
			geom_smooth(data = tab, aes(x = year, y = rate),
							colour = "#990000",
							size = 1))

		isolate(print(p))
	})
	

	output$filmidnum <- renderUI({
		input$goFilmButton
		input$goButton
		
		tab <- isolate(select(tablica_osoby(input$filmosoba, input$filmrola), title))
		lista <- paste(tab$title)
		selectInput("filmidnum", "Film:", lista)
	})
})
