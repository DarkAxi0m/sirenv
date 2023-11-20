import figlet from "figlet";
import process from "process";
import { Config, loadConfig, configEdit } from "./Config";
import { SBASStart } from "./SBASStart";
import { serve } from "./serve";

const { AutoComplete } = require("enquirer");

//let hr = (l = process.stdout.columns) => console.log("-".repeat(l));

interface Option {
  command: string;
  description: string;
  action?: (config: Config) => Promise<string | void>;
  options?: Option[];
}
export const GlobalOptions: Option[] = [
  { command: "serve", description: "Start Bun Server", action: serve },
  { command: "edit", description: "Edit Stuff", action: configEdit },
  {
    command: "sbas",
    description: "Start SBAS Entry",
    options: [
      { command: "sbas1", description: "111", action: SBASStart },
      { command: "sbas2", description: "222", action: SBASStart },
    ],
  },
];


// Define a configuration object

async function displayMenu(
  config: Config,
  options: Option[] = GlobalOptions,
  level: string = ""
) {
  const prompt = new AutoComplete({
    name: "command",
    message: level + " Command:",
    limit: 10,
    initial: 1,
    choices: [...options.map((option) => option.command), "exit"],
  });

  await prompt
    .run()
    .then(async (answer: string) => {
      if (answer === "exit") {
        process.exit(1);
      }
      const selectedOption = options.find(
        (option) => option.command === answer
      );
      if (selectedOption) {
        if (selectedOption.action) {
          let res = await selectedOption.action(config);
          console.log(res);
        }
        if (selectedOption.options) {
          return displayMenu(
            config,
            selectedOption.options,
            selectedOption.command
          );
        }
      } else {
        console.log("Invalid choice. Please enter a valid option.");
      }
    })
    .catch(console.error);
  return displayMenu(config, options, level);
}

let app = async () => {
  let config = await loadConfig();
  console.log(figlet.textSync("SandBox!"));
  if (process.argv.length > 3) {
    const command = process.argv[3];
    const selectedOption = GlobalOptions.find(
      (option) => option.command === command
    );
    if (selectedOption) {
      if (selectedOption.command === "exit") {
        console.log("Exiting...");
      } else {
        selectedOption.action &&
          console.log(await selectedOption.action(config));
        selectedOption.options &&
          (await displayMenu(
            config,
            selectedOption.options,
            selectedOption.command
          ));
      }
      process.exit(0);
    } else {
      console.log("Invalid command. Available commands:");
      GlobalOptions.forEach((option) => {
        if (option.command !== "exit") {
          console.log(`${option.command}: ${option.description}`);
        }
      });
      process.exit(1);
    }
  } else {
    displayMenu(config);
  }
};

//process.exit()
app();
