-   Identify what details I want to pull from these summaries
    -   Look at samples of all movies and start categorizing subgenres, details about protagonists, details about antagonists, details about setting, details about conflict
    -   Could start from seeing what AI turns up from these summaries and reacting to that
-   Write prompt design markdown document
    -   Write in markdown
    -   Provide top level summary of what the chatbot is "You are..."
    -   Provide examples of summaries and the expected output for each field
        -   Within example, provide description of what the example is trying to accomplish
    -   Can give multiple results for subgenres
    -   For structured output, we'll use:

```{r}

type_characteristics <- type_object(
    primary_sub_genre = type_enum(c("phobia", "madness", "home invasion", "slasher", "backwoods horror", "torture", "body horror", "splatter", "cannibal", "extreme", "zombies", "virus", "vampire", "werewolf", "classic and mythological","neo-monsters","nature","giant creatures", "small creatures", "sci-fi and aliens", "ghost and spirits", "haunted house", "possession", "devils, demons, and hell", "witches", "supernatural power","horror comedy", "parody horror", "Lovecraftian/Cosmic horror", "gothic horror","found footage","folk horror", "post-apocalyptic"),"Identify the primary sub-genre of the movie"),
    secondary_sub_genre <- type_enum(c("phobia", "madness", "home invasion", "slasher", "backwoods horror", "torture", "body horror", "splatter", "cannibal", "extreme", "zombies", "virus", "vampire", "werewolf", "classic and mythological","neo-monsters","nature","giant creatures", "small creatures", "sci-fi and aliens", "ghost and spirits", "haunted house", "possession", "devils, demons, and hell", "witches", "supernatural power","horror comedy", "parody horror", "Lovecraftian/Cosmic horror", "gothic horror","found footage","folk horror", "post-apocalyptic"),"Identify the secondary sub-genre of the movie. You may not choose {primary_sub_genre} as it has been chosen already."),
    tertiary_sub_genre <- type_enum(c("phobia", "madness", "home invasion", "slasher", "backwoods horror", "torture", "body horror", "splatter", "cannibal", "extreme", "zombies", "virus", "vampire", "werewolf", "classic and mythological","neo-monsters","nature","giant creatures", "small creatures", "sci-fi and aliens", "ghost and spirits", "haunted house", "possession", "devils, demons, and hell", "witches", "supernatural power","horror comedy", "parody horror", "Lovecraftian/Cosmic horror", "gothic horror","found footage","folk horror", "post-apocalyptic"),"Identify the tertiary sub-genre of the movie. You may not choose {primary_sub_genre} or {secondary_sub_genre} as they have been chosen already."),
    protagonist_type = type_enum(c("human", "human with extra powers", "possessed human", "non-human entity", "unknown"),"The protagonist is a "),
    antagonist_type = type_enum(c("human", "human with extra powers", "possessed human", "non-human entity", "unknown"),"The antagonist is a "),
    protagonist_gender = type_enum(c("male", "female", "androgynous", "unknown"), "The protagonist's gender is "),
    antagonist_gender = type_enum(c("male", "female", "androgynous", "unknown"), "The antagonist's gender is "),
    protagonist_age = type_enum(c("under 18", "18-30", "30-50", "50+", "unknown"), "The protagonist is within the following age range"),
    antagonist_age = type_enum(c("under 18", "18-30", "30-50", "50+", "unknown"), "The antagonist is within the following age range"),
    setting_time = type_enum(c("past","present","future"), "The movie was filmed in {year}. The movie is set in the "),
    setting_location = type_enum(c("house", "forest", "big city", "small town", "rural","outer space", "unknown"), "The movie is primarily located in the ")
  )

```

-   Write another prompt design that allows the LLM to use information from outside of the summary (more prone to hallucinations)
    -   This one can also use the title column to get info about said movie. The first will only use the summary field
    -   "You will only use information from the summary that I provide you. Even if you know what movie the summary is referring to, do not attempt to answer the question with outside information. Just use your own reasoning to answer the question."
-   Look into parallel chat or batch chat
-   Ensure chatbot provides structured outputs
-   Use it to mutate columns on the movies dataframe

## Classifications:

### Sub-genres:

Taken from <https://nofilmschool.com/best-minnesota-accents-movies>

Removed genres defined by their visual aesthetic, including "arthouse" from psychological, "crime and giallo" from killer.

May opt for second sub-genre evaluation

### Character classifications

Human?: Human, alien, supernatural entity (e.g. ghost, demon), specific monster from folklore (werewolf, vampire, mummy)

Gender: Male, female, androgynous, unknown

Age: Under 18, 18-30, 30-50, 50+, unclear

### Setting

Set in time outside of current year?: Past, present, future and uses the year column as context. If unclear, then it assumes present day

Location: House, forest, big city, small town, rural, unknown
