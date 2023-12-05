Summer Ely (Release 10%, Overall 30%)
- Search page and recipe page
- Implemented a search page with a search bar component where you can type in a nationality (eg. "American") and it will call the [MealDB API](https://www.themealdb.com/api.php) which will return a list of recipes that are displayed in a table view.
- Implemented a recipe page that appears when a recipe is selected from the tableview. Recipe name, image, category, ingredients, and instructions are displayed here.
- Created "Recipe", "Recipes", "FullRecipe", and "RecipeResponse" classes to help with parsing API responses and storing data about recipes. 
- Added segues from home page to search page and search page to individual recipe page.
- Added custom font and improved UI of search/recipes page

Trent Ho (Release 30%, Overall 22.5%)
- Navigation Tab Bar
- Implemented the NavTab bar and created the icons for the home, upload recipe, and favorites sections.
- Added segues so that the Tab bar is present in other screens.
- Filtering System
  - Integrated a filtering system within the search functionality that filters out recipes based on user-specified allergens and dietary restrictions.
  - Enhanced the Recipe and FullRecipe models to handle the filtering logic, ensuring recipes with certain ingredients are excluded from the search results.
- Dark Mode
  - Implemented dark mode functionality within the app, allowing users to toggle between light and dark themes.
  - Enabled the dark mode feature to apply across the entire app, persisting user preferences and ensuring a consistent look and feel.

Anne-Marie Prosper (Release 30%, Overall 25%)
- User Signup & Login screen
- Added segues to transition from screens to home screen upon successful login.
- Implemented basic user signup/login functionality using email addresses and integrate with Firebase Authentication.
  - Added alert error messages whenever signin or signup is unsuccessful.
- Set up Firestore database, allowing each user to store their: name, allergens, and dietary restrictions.
- Created Settings View Controller 
  - Enabled user's to edit (adding or removing) their allergens in the database
  - Display the information within the database to the user.
  - Added log out functionality, segues back to log in screen.

Faiza Rahman (Release 30%, Overall 22.5%)
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


### Group number: 13
### Team Members: Summer Ely, Trent Ho, Anne-Marie Prosper, Faiza Rahman
### Name of project: Passplate
### Dependencies: Xcode 15, latest swift version, (Put in pods/frameworks that need to be installed first here)

### Special Instructions (this is just place holder will change later)
* Use an iPhone 14 pro or iPhone 15 pro Simulator
  *  Before running the app, run "pod install" inside the DragonWar folder where the podfile is located
  * To login with Facebook, use this test account: email: DragonWarTest@gmail.com password: DragonWar
  *  To test the connection between two players, you need to set two player mode on, and you need to run it on an iPhone and a simulator at the same time (or 2 simulators)


## Features

| Feature              | Description                                           | Release Planned | Release Actual | Deviations                 | Who/Percentage Worked on                |
|----------------------|-------------------------------------------------------|-----------------|----------------|----------------------------|-----------------------------------------|
| Search Page          | Implementation of a search page with API integration for fetching recipes based on nationality and name | Alpha           | Alpha          | On the search results screen we planned to display: the recipe image, name, description and cook time; however, the screen is only able to display the recipe image and name. This reduction is because the recipe description and cook time are not retrievable through the API call.  | Summer 75% Faiza 25%  |
| Recipe Page          | Detailed recipe display including name, image, category, ingredients, and instructions | Alpha           | Alpha          | None                       | Summer 75% Faiza 25%    |
| Navigation Tab Bar   | Custom navigation bar with icons for home, upload recipe, and favorites, with integrated segues | Alpha            | Alpha           | None                       | Trent 100%    |
| Filtering System     | System to filter recipes based on user-specified allergens and dietary restrictions | Beta            | Beta           | None                       | Trent 100%   |
| Dark Mode            | Implementation of dark mode functionality across the app | Beta            | Beta           | None                       | Trent 100%    |
| User Signup & Login  | Basic authentication system with email, integrated with Firebase Authentication | Alpha           | Alpha          | None                       | Annie 100%  |
| Settings View Controller | Allows users to edit their allergens and dietary restrictions, and log out functionality | Beta            | Beta           | In our original design, we had both a profile page and a settings page. However, based on the feedback from our Design, we realized that the profile and "social media" aspect wasn't in the scope or focus of our app. Therefore, we decided to combine and simplify this into just the settings page. | Annie 100% |
| Logo and Home Screen Design | Design of the logo, splash page, and overall homepage layout | Alpha           | Alpha          | None | Faiza 100%  |
| Map Component | Ability to scroll around on the World Map and click on a country will take you to the search results for that country | Beta | Beta | None | Faiza 100% | 
| Favorites Recipe Page | | Final |Final | | Summer 75% Annie 25% |
| Uploading Recipes | | Final | Final | | Annie 100% |
