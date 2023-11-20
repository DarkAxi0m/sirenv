import process from "process";
import { Server } from "bun";
import { Config } from "./Config";
import { GlobalOptions } from "./sandbox";

let server: Server | null = null;
// Define your controller functions
export async function serve(config: Config) {
  server = Bun.serve({
    fetch(req) {
      const htmlHeader = {
        headers: {
          "Content-Type": "text/html",
        },
      };
      const url = new URL(req.url);
      if (url.pathname === "/") {
        let links = GlobalOptions
          .map((option) => {
            return `<a href='/${option.command}'>${option.description}</a>`;
          })
          .join("<br/>");
        return new Response(`<h1>${config.who}</h1>${links}`, htmlHeader);
      }

      const selectedOption = GlobalOptions.find(
        (option) => `/${option.command}` === url.pathname
      );
      if (selectedOption) {
        if (selectedOption.action) {
          let res = selectedOption.action(config);
          console.log(res);
          return new Response(
            `<h1>${selectedOption.command}: <small>${selectedOption.description}</small></h1><pre>${res}</pre>`,
            htmlHeader
          );
        } else {
          setTimeout(() => {
            console.log("Stopping server...");
            console.log(server);
            server?.stop(true);
            process.exit(1);
          }, 500);
          return new Response(`<h1>Good Buy</h1>`, htmlHeader);
        }
      }

      if (url.pathname === "/blog") return new Response("$Blog!");
      return new Response("404!");
    },
  });

  return `Started Bun Server: http://${server.hostname}:${server.port}`;
}
