# My Haskell Project

This project is a Haskell application that implements a state machine using a JSON-like structure for configuration.

## Project Structure

- `src/`: Contains the source code for the application.
  - `Main.hs`: Entry point of the application.
  - `Parser.hs`: Contains the logic for parsing the JSON-like structure.
  - `StateMachine.hs`: Implements the state machine logic.

- `Makefile`: Build instructions for compiling the Haskell files and running the executable.

- `package.yaml`: Configuration file for the Haskell project, specifying dependencies and settings.

## Building the Project

To build the project, run the following command in the project root directory:

```
make
```

## Running the Application

After building, you can run the application with:

```
make run
```

## Usage

The application parses a JSON-like structure and executes a state machine based on the parsed data. Ensure that the input data is correctly formatted to avoid parsing errors.

## Dependencies

This project may require specific Haskell libraries. Please refer to the `package.yaml` file for details on dependencies.