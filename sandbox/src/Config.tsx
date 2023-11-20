import { FormProps, Form } from "ink-form";

import React, { useState, useEffect } from "react";
import { render, Text } from "ink";

import path from "path";
import process from "process";
import { MenuItemProps } from "./app";
import Spinner from "ink-spinner";
import { prisma } from "./dbclient";
import { Prisma } from "@prisma/client";

class sbasDetails {
  name: string = "";
}

class Server {
  name: string = "";
  user: string = "";
  host: string = "";
}

export class Config {
  cwd: string = "";
  who: string = "";
  sbas: sbasDetails = new sbasDetails();
  servers: Server[] = [];
}

export let ConfigEdit: React.FC<MenuItemProps> = ({ close, config }) => {
  const [form, setForm] = useState<FormProps | null>(null);
  const [saving, setSaving] = useState<boolean>(true);

  const [customers, setCustomers] = useState<{ value: string }[] | null>(null);
  React.useEffect(() => {
    prisma.customer
      .findMany({
        where: {
          Active: 1,
        },
        orderBy: {
          Name: "asc",
        },
      })
      .then((c) => {
        let x = c.map((v) => {
          return { value: v.Name };
        });
        setCustomers(x);
        setSaving(false);
      });
  }, []);

  React.useEffect(() => {
    if (config && customers) {
      setTimeout(() => {
        const form: FormProps = {
          form: {
            title: "Sandbox Config",
            sections: [
              {
                title: "Main",
                fields: [
                  {
                    type: "string",
                    name: "who",
                    label: "Client Name",
                    initialValue: config.who,
                  },
                  {
                    type: "string",
                    name: "cwd",
                    label: "Working Dir",
                    initialValue: config.cwd,
                  },
                ],
              },
              {
                title: "SBAS",
                fields: [
                  {
                    type: "select",
                    name: "sbasName",
                    label: "SBAS Name",
                    initialValue: config.sbas?.name,
                    options: customers,
                  },
                ],
              },
            ],
          },
        };

        setForm(form);
      }, 1);
    }
  }, [config, customers]);

  return (
    <>
      {saving ? (
        <Text>
          <Text color="green">
            <Spinner type="dots" />
          </Text>
          {" Please Wait..."}
        </Text>
      ) : (
        form && (
          <Form
            {...form}
            onSubmit={(result: any) => {
              config.cwd = result.cwd;
              config.who = result.who;
              config.sbas.name = result.sbasName;
              console.clear();
              setSaving(true);
              saveConfig(config).then(() => {
                setTimeout(() => {
                  close();
                }, 200);
              });
            }}
          />
        )
      )}
    </>
  );
};

export let saveConfig = async (c: Config) => {
  await Bun.write(c.cwd + "/.sandbox.json", JSON.stringify(c, null, 2));
  console.log("Saved Config");
};

export let loadConfig = async (): Promise<Config> => {
  const currentWorkingDirectory =
    process.argv.length >= 3 ? process.argv[2] : process.cwd();
  const defaultConfig = new Config();
  defaultConfig.cwd = currentWorkingDirectory;
  defaultConfig.who = path.basename(currentWorkingDirectory);

  let cf = Bun.file(currentWorkingDirectory + "/.sandbox.json");
  if (cf.size <= 0) {
    await saveConfig(defaultConfig);
    return defaultConfig;
  }

  return await cf.json().then((v: Partial<Config>) => {
    const c: Config = { ...defaultConfig, ...v };
    return c;
  });
};
