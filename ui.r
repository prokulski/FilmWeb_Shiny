shinyUI(fixedPage(
  fixedRow(
  	column(2,
#    	numericInput("filmidnum", "Podaj ID filmu:", 624),
    	# filtr dla nazwiska
    	textInput("filmosoba", "Imie i nazwisko osoby:", "David Lynch"),
    	# filtr na role
    	radioButtons("filmrola", "Rola w filmie:",
    					 c("Rezyseria" = 1,
    					   "Scenariusz" = 2,
    					   "Muzyka" = 3,
    					   "Zdjecia" = 4,
    					   "Obsada" = 6)),
    	actionButton("goButton", "Szukaj filmow")
      ),

	column(6,
		plotOutput("wykres"),
		hr(),
		tableOutput("tabela")
	),
	column(4,
		uiOutput("filmidnum"),
		actionButton("goFilmButton", "Info o filmie"),
		hr(),
    	htmlOutput("previewpage")
    )
  )
))

