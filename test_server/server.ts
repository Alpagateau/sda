import { decodeBase64, encodeBase64 } from "jsr:@std/encoding/base64";
import { decodeHex, encodeHex } from "jsr:@std/encoding/hex";

function get_today(req : Request) : Promise<Response> | Response {
  const bytes = Deno.readFile("image.png");
  const base64 = btoa(
    Array.from(bytes, (byte) => String.fromCharCode(byte)).join("")
  );
  return Response.json(
    {
      name: "Player",
      date: "03-04-2026",
      image: base64
    });
}

function update_server(e){return Response.json({text:"Thx"});}

function handler(req : Request) : Promise<Response> | Response {
  switch (req.method) {
    case "POST":
      return update_server(req);
    case "GET":
      return get_today(req);
  }
}

function start_server(port = 8000){
  return Deno.serve({port}, handler);
}

start_server();
