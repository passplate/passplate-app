# passplate-app

Contributions:

Summer Ely (50%)
- Search page and recipe page
- Implemented a search page with a search bar component where you can type in a nationality (eg. "American") and it will call the [MealDB API](https://www.themealdb.com/api.php) which will return a list of recipes that are displayed in a table view.
- Implemented a recipe page that appears when a recipe is selected from the tableview. Recipe name, image, category, ingredients, and instructions are displayed here.
- Created "Recipe", "Recipes", "FullRecipe", and "RecipeResponse" classes to help with parsing API responses and storing data about recipes. 
- Added segues from home page to search page and search page to individual recipe page.

Trent Ho (15%)
- Navigation Tab Bar
- Implemented the NavTab bar and created the icons for the home, upload recipe, and favorites sections.
- Added segues so that the Tab bar is present in other screens.
  - Added Placeholder segues and screens for the favorites and upload recipe sections.

Anne-Marie Prosper (20%)
- User Signup & Login screen
- Added segues to transition from screens to home screen upon successful login.
- Implemented basic user signup/login functionality using email addresses and integrate with Firebase Authentication.
  - Added alert error messages whenever signin or signup is unsuccessful.


Faiza Rahman (15%)
- Home Screen
- Designed a basic homepage layout in Interface Builder featuring:
  - Placeholder for the interactive world map.
  - Search bar component.
  - Placeholder for the favorites icon.


Deviations:
- The search results only show the recipe image and recipe name instead of also including a description and a cook time like in our design. Only the image and name are displayed on the search results page because those are the only values the API call returns.
