# Classifying horror movies using Ellmer

- [Overview](#overview)
- [Methodology](#methodology)
- [Notes](#notes)

## Overview

What is a Maryland horror movie? There are 60 of them set in the state according to an extensive database compiled by a Reddit user. Those range from the wildly popular "The Blair Witch Project" to some very small productions. I used OpenAI’s large language model GPT 4.1 to classify key characteristics of these 4,000+ horror films, including subgenre, setting and characteristics of the protagonist. This allowed me to identify a spike in the horror subgenres of found footage, backwoods, and isolation following the release of "The Blair Withc Project."

The initial database contained the title of the horror movie, the year of its release, its IMDb description and the state that it was set in. The Reddit user compiled the list of horror movies using classifications from IMDb and Letterboxd to determine if the movie belonged in the horror genre. They then studied the movie to determine where it was set, using explicit clues, such as direct quotes, and subtler clues, such as license plates.

## Methodology

Much of this analysis is facilitated by Ellmer, a package in R that interfaces with large language models. 

I began by creating an object which defined the structured data I wanted the LLM to extract. This included the primary subgenre, secondary subgenre, tertiary subgenre, species of the protagonist, species of the antagonist, gender of the protagonist, gender of the antagonist, age of the protagonist, age of the antagonist, setting time period, and setting location. The 33 different subgenres were identified by [No Film School](https://nofilmschool.com/horror-subgenres). The object was composed of various enum objects which restricts the model to a finite set of options per characteristic.

I then created a custom system prompt to instruct the model on how to classify horror movies. I provided it with the following:

- Its "identity"
- The task it is assigned to complete
- Definitions of each subgenre with an example
- Instructions on how to choose a subgenre
- Definitions and examples of the classifications pertaining to protagonist, antagonist, and setting
- Five examples of how the model should classify movies

I then tested various models from Google and OpenAI to determine which model had the most accurate classifications. GPT 4.1 classified movies 100% accurately in my testing.

Because the classification process is slow and costly (the entire analysis cost $40), I batch the movies by state then combine the datasets at the end to avoid losing analysis along the way in R's pipeline.

## Notes

Running the analysis file requires API keys with OpenAI, Claude, and Gemini. The entire analysis requires $40 of OpenAI tokens and takes roughly 24 hours.