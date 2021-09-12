#/ Copyright 2021, gotthumb 
#/ All rights reserved.
#/ Use of this source code is governed by a BSD-style license that can be
#/ found in the LICENSE file.
#
# perl 5, version 16
# thumb エミュレータ  r0p0-alpha
# -------------------------------------------------------
#/ 長い間、来てください。

#/ rule $ T/F判定実行
#/      () 注釈  処理後にスタックされる値
#/      ??       要検討
#/      delimit  改行
#
#
# :thumb ファイル名 thumbエミュレータ
# :thumbエミュレータ $ 配列を宣言する
#                      エラー
#                    $ ファイルオブジェクト_開く
#                      エラー
#                    $ コード_読出す
#                      エラー
#                    $ コード_実行
#                      エラー
#                    $ ファイルオブジェクト_閉じる
#                      エラー
# :配列を宣言する 新規 reg[] 10 配列宣言
# :ファイルオブジェクト_開く 

   #my $file = $0;
   my $file = "../test/thumbcode1.bin";
   open my $fh, "<", $file or die $!;
   binmode($fh);

# :コード_読出す 読出し $ (16bit値) 

   my $size = -s $file;
   my $buf = 0;
   my $read = read( $fh, my $buf, $size, 0);
   die "Cannot read '$file' : $!" unless defined $read;

   my @mem = unpack("H2"x $size, $buf );

#                         エラー

   if ( $size > 256 )
   {
      print "読込んだコードの大きさが、制限値を越えています。\n";
      exit;
   }


# :コード_実行 dup 0xf000 & 0x4000 ?? = $ 実行A 
#              dup 0xf000 & 0x8000 ?? = $ 実行B

   my $opcode = 0;
   my $rgd = 0;
   my $rgm = 0;
   my $rgn = 0;
   my $im8 = 0;
   my $pc = 0;

   $opcode = hex("0x".$mem[$pc+1].$mem[$pc]);

   # printf " mem[$pc] = %04x", $opcode ;

   # Rd = u8
   if ( ( $opcode & 0xf800 ) == 0x2000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x700 ) / 0x100;
      $im8 = ( $opcode & 0xff );
      printf "mov r%d, #%d\n", $rgd, $im8;
   }
   # Rd = Rm
   elsif ( ( $opcode & 0xff00 ) == 0x4600 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0080 ) / 0x10 + ( $opcode & 0x0007 ) ;
      $rgm = ( $opcode & 0x0078 ) / 0x8 ;
      printf "mov r%d, r%d\n", $rgd, $rgm;
   }
   # Rd += u8
   elsif ( ( $opcode & 0xf800 ) == 0x3000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "add r%d, r%d, #%d\n", $rgd, $rgd, $im8;
   }
   # Rd -= u8
   elsif ( ( $opcode & 0xf800 ) == 0x3800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "sub r%d, r%d, #%d\n", $rgd, $rgd, $im8;
   }
   # Rd = PC + u8
   elsif ( ( $opcode & 0xf800 ) == 0xa000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "ldr r%d, [ PC, #%d ]\n", $rgd, $im8;
   }
   # Rd += Rm
   elsif ( ( $opcode & 0xff00 ) == 0x4400 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0080 ) / 0x10 + ( $opcode & 0x0007 ) ;
      $rgm = ( $opcode & 0x0078 ) / 0x8 ; 
      printf "add r%d, r%d, r%d\n", $rgd, $rgd, $rgm;
   }
   # Rd = Rn + u3
   elsif ( ( $opcode & 0xfe00 ) == 0x1c00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ; 
      $im3 = ( $opcode & 0x01c0 ) / 0x40 ;
      printf "add r%d, r%d, #%d\n", $rgd, $rgn, $im3 ;
   }
   else
   {
      $pc = $pc + 2;
   }

   if ($pc > $size) 
   {
      print "over flow.\n";
         break;
   }

#                               :
#
#
#
#
# :実行A mov_r0_r1 $ (T)
#                    エラー
# :mov_r0_r1 reg[] 2 + reg[] 2 mov
#


# : ファイルオブジェクト_閉じる

   close $fh;


