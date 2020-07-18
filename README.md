# okonomi/おこのみ

DB用意するのダルいけどfile直書きして毎回echo/cat/grepとかダルいので作ったkvsっぽいスクリプト

## usase

```
git clone https://github.com/ToshihitoKon/okonomi.git
cd okonomi
./kvs.sh
```

データはstateにtsvとして保存されます

## 出来ること

- key/valueを保存できます、一応tab以外なら保存出来るけどshell的に意味を持つものは入れないほうが良い
- key/valueにgroupを追加で与えられます、group単位で値の読み出しや、group一覧の表示ができます
