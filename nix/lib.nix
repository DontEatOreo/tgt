{
  mkTgtPath = file: ".tgt/config/${file}";
  mkAbsolutePath = path: home: "${home}/${path}";

  kb = key: action: description: { inherit key action description; };

  mkColor = value: "#${value}";
  mkStyle =
    fg: bg:
    {
      bold ? false,
      underline ? false,
      italic ? false,
    }:
    {
      inherit
        fg
        bg
        bold
        underline
        italic
        ;
    };
}
