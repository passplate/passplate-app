# passplate-app

Contributions:

Summer Ely (Release 10%, Overall 30%)
- Search page and recipe page
- Implemented a search page with a search bar component where you can type in a nationality (eg. "American") and it will call the [MealDB API](https://www.themealdb.com/api.php) which will return a list of recipes that are displayed in a table view.
- Implemented a recipe page that appears when a recipe is selected from the tableview. Recipe name, image, category, ingredients, and instructions are displayed here.
- Created "Recipe", "Recipes", "FullRecipe", and "RecipeResponse" classes to help with parsing API responses and storing data about recipes. 
- Added segues from home page to search page and search page to individual recipe page.
- Added custom font and improved UI of search/recipes page

Trent Ho (15%)
- Navigation Tab Bar
- Implemented the NavTab bar and created the icons for the home, upload recipe, and favorites sections.
- Added segues so that the Tab bar is present in other screens.
- Filtering System
  - Integrated a filtering system within the search functionality that filters out recipes based on user-specified allergens and dietary restrictions.
  - Enhanced the Recipe and FullRecipe models to handle the filtering logic, ensuring recipes with certain ingredients are excluded from the search results.
- Dark Mode
  - Implemented dark mode functionality within the app, allowing users to toggle between light and dark themes.
  - Enabled the dark mode feature to apply across the entire app, persisting user preferences and ensuring a consistent look and feel.

Anne-Marie Prosper (20%)
- User Signup & Login screen
- Added segues to transition from screens to home screen upon successful login.
- Implemented basic user signup/login functionality using email addresses and integrate with Firebase Authentication.
  - Added alert error messages whenever signin or signup is unsuccessful.
  
Faiza Rahman ()
- Logo design
- Home Screen
- Designed a basic homepage layout in Interface Builder featuring:
  - Placeholder for the interactive world map.
  - Search bar component.
  - Placeholder for the favorites icon.
- Added and implemented the logic for the map view
  - Used Geocoder and the API's list of countries to add coordinates for each country included in the API
  - Implemented the ability to run a search of a coordinate's associated recipes (ex. when the USA coordinate is clicked, it runs a search for "American" food)
- Updated UI for login/sign-up pages past the barebones stage
- Added UI to the upload recipes/favorites pages


Deviations:
- On the search results screen we planned to display: the recipe image, name, description and cook time; however, the screen is only able to display the recipe image and name. This reduction is because the recipe description and cook time are not retrievable through the API call.
