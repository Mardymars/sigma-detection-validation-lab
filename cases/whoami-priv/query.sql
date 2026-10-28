SELECT * FROM logs WHERE (Image LIKE '%\\whoami.exe' ESCAPE '\' OR OriginalFileName='whoami.exe') AND (CommandLine LIKE '% /priv%' ESCAPE '\' OR CommandLine LIKE '% -priv%' ESCAPE '\')
