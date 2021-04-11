特定の製品に依存しない、thumb命令を処理するソフトウェアエミュレータです。

以下の問題([引用元](https://stackoverflow.com/questions/5495594/software-simulation-from-arm-cortex-m0"))が、あるようです。
There is no FOSS simulator. ARM documentation license prohibit 
documentation use for making simulator. You have to pay money to 
ARM to use documentation for simulation purposes and so all ARM 
simulators for latest architectures are non free.

従って、[この情報源](https://ichigojam.github.io/asm15/armasm.html")に基づいてエミュレータの仕様を作ります。
詳細は、SPECIFICATIONを参照してください。


使用するツールのバージョンは、当面以下の通りです。

   |tool name | version                                                  |
   |----------|----------------------------------------------------------|
   |  java    | openjdk version "1.8.0_252"                              |
   |          | OpenJDK Runtime Environment (build 1.8.0_252-b09)        |
   |          | OpenJDK 64-Bit Server VM (build 25.252-b09, mixed mode)  |
   |          |                                                          |
   |  perl    | perl 5, version 16, subversion 3 (v5.16.3)               |
   |          | built for x86_64-linux-thread-multi                      |
   |          |                                                          |
   |  python  | Python 2.7.5                                             |

  * m0plus.javaは、将来削除するか、又は、別な言語に変更する可能性があります。


本プロジェクトに参加したい方は、以下の２点を含めて連絡ください。

   1) 自らの言葉で、且つ、日本語(下手でも通じればOK)で、他の類似プロジェクトとの違いを説明してください。

   2) 実行ファイルが、より良く正常終了するように改善箇所を１箇所以上、提示してください。

   * 参加の注意点としては、公開プロジェクトですので理由の通知無くメンバーを削除する場合がある事を了解ください。
     (ローカルコピーの処分について責任は負いません)
