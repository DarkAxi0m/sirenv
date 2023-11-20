import { Config , saveConfig} from "./Config";

const { AutoComplete } = require("enquirer");

import {prisma} from './dbclient'


// use `prisma` in your application to read and write data in your DB

let chooseSbasName = async (config: Config) => {
 const custs = await prisma.Customer.findMany()
 const prompt = new AutoComplete({
    name: "sbascompany",
    message: "SBAS Name",
    limit: 10,
    choices: custs.map((v)=>v.Name) 
  });

  return prompt
    .run()
    .then((answer: string) => {
      config.sbas = { name: answer };

      return saveConfig(config);
    })
    .catch(console.error);
};

let checkdetails = async (config: Config) => {
console.log(config)

    if (!config.sbas) {
    console.log('name')
    await chooseSbasName(config);
  }
};

export async function SBASStart(config: Config): Promise<string> {
  await checkdetails(config);
  
  console.log(config);
  return "Function 2 executed";
}

