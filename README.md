# CPSC 4620 Project
### Fall 2024 - Professor Van Scoy
### Jackson Van Hyning & Kevin Lin

## Setting up the Java Environment
1. Install IntelliJ - https://www.jetbrains.com/idea/download/?section=windows
   - Select options to Update PATH variable, Update Context Menu, and to recognize .java and .gradle files
   - Computer will need to restart for this to take effect
2. Clone this repository somewhere
3. Start IntelliJ and click "Open" -> Select the 'cpsc4620' folder from within this repository
4. Once the project is opened, go to the top left and clicked File -> Project Structure
5. First, open the dropdown menu next to SDK and click "Install SDK"
   - Use whatever the most recent version is
6. Once the Java SDK is installed, then go to 'Libraries' and click the + Icon
7. Navigate inside the 'mysql-connector' folder in this repo and click on the .jar file, then click Apply to add it to the Library
8. Finally, modify the values in DBConnector.java to authenticate to your DB
   - IMPORTANT: Leave the "jdbc:mysql://" at the beginning of the URL - this is needed to work with the driver
