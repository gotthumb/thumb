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
   my $u5  = 0;
   my $pc = 0;

   $opcode = hex("0x".$mem[$pc+1].$mem[$pc]);

   # printf " mem[$pc] = %04x", $opcode ;

   # Rd = u8
   if ( ( $opcode & 0xf800 ) == 0x2000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x700 ) / 0x100;
      $im8 = ( $opcode & 0xff );
      printf "R%d = #%d\n", $rgd, $im8;
   }
   # Rd = Rm
   elsif ( ( $opcode & 0xff00 ) == 0x4600 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0080 ) / 0x10 + ( $opcode & 0x0007 ) ;
      $rgm = ( $opcode & 0x0078 ) / 0x8 ;
      printf "R%d = R%d\n", $rgd, $rgm;
   }
   # Rd += u8
   elsif ( ( $opcode & 0xf800 ) == 0x3000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "R%d = R%d + #%d\n", $rgd, $rgd, $im8;
   }
   # Rd -= u8
   elsif ( ( $opcode & 0xf800 ) == 0x3800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "R%d = R%d + #%d\n", $rgd, $rgd, $im8;
   }
   # Rd = PC + u8
   elsif ( ( $opcode & 0xf800 ) == 0xa000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0700 ) / 0x100 ;
      $im8 = ( $opcode & 0xff );
      printf "R%d = PC + #%d ]\n", $rgd, $im8;
   }
   # Rd += Rm
   elsif ( ( $opcode & 0xff00 ) == 0x4400 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0080 ) / 0x10 + ( $opcode & 0x0007 ) ;
      $rgm = ( $opcode & 0x0078 ) / 0x8 ; 
      printf "R%d = R%d + R%d\n", $rgd, $rgd, $rgm;
   }
   # Rd = Rn + u3
   elsif ( ( $opcode & 0xfe00 ) == 0x1c00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ; 
      $im3 = ( $opcode & 0x01c0 ) / 0x40 ;
      printf "R%d = R%d + #%d\n", $rgd, $rgn, $im3 ;
   }
   # Rd = Rn - u3
   elsif ( ( $opcode & 0xfe00 ) == 0x1e00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ; 
      $im3 = ( $opcode & 0x01c0 ) / 0x40 ;
      printf "R%d = R%d - #%d\n", $rgd, $rgn, $im3 ;
   }
   # Rd = Rn + Rm
   elsif ( ( $opcode & 0xfe00 ) == 0x1800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ; 
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      printf "R%d = R%d + R%d\n", $rgd, $rgn, $rgm ;
   }
   # Rd = Rn - Rm
   elsif ( ( $opcode & 0xfe00 ) == 0x1a00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ; 
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      printf "R%d = R%d - R%d\n", $rgd, $rgn, $rgm ;
   }
   # Rd = -Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4240 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      printf "R%d = -R%d\n", $rgd, $rgm ;
   }
   # Rd *= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4340 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      printf "R%d *= R%d\n", $rgd, $rgm ;
   }
   # Rd = Rm << u5
   elsif ( ( $opcode & 0xf800 ) == 0x0 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "R%d = R%d << %d\n", $rgd, $rgm, $u5 ;
   }
   # Rd = Rm >> u5
   elsif ( ( $opcode & 0xf800 ) == 0x800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "R%d = R%d >> %d\n", $rgd, $rgm, $u5 ;
   }
   # Rd <<= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4080 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d <<= R%d\n", $rgd, $rgm ;
   }
   # Rd >>= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x40c0 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d >>= R%d\n", $rgd, $rgm ;
   }
   # Rd = ~Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x43c0 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d = ~R%d\n", $rgd, $rgm ;
   }
   # Rd &= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d &= R%d\n", $rgd, $rgm ;
   }
   # Rd |= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4300 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d |= R%d\n", $rgd, $rgm ;
   }
   # Rd ^= Rm
   elsif ( ( $opcode & 0xffc0 ) == 0x4040 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = 0 ;
      $rgm = ( $opcode & 0x0038 ) / 0x8 ;
      $u5  = 0 ;
      printf "R%d ^= R%d\n", $rgd, $rgm ;
   }
   # Rd = [Rn + u5]
   elsif ( ( $opcode & 0xf800 ) == 0x7800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "R%d = [R%d + %d]\n", $rgd, $rgn, $u5 ;
   }
   # Rd = [Rn + u5]W
   elsif ( ( $opcode & 0xf800 ) == 0x8800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "R%d = [R%d + %d]W\n", $rgd, $rgn, $u5 ;
   }
   # Rd = [Rn + u5]L
   elsif ( ( $opcode & 0xf800 ) == 0x6800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "R%d = [R%d + %d]L\n", $rgd, $rgn, $u5 ;
   }
#  # Rd = [PC + u8]L
#  elsif ( ( $opcode & 0xf800 ) == 0x4800 )
#  {
#     $pc = $pc + 2;
#     $rgd = ( $opcode & 0x0007 ) ;
#     $rgn = ( $opcode & 0x0038 ) / 0x8 ;
#     $rgm = 0 ;
#     $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
#     printf "R%d = [R%d + %d]L\n", $rgd, $rgn, $u5 ;
#  }
   # Rd = [Rn + Rm]
   elsif ( ( $opcode & 0xfe00 ) == 0x5c00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "R%d = [R%d + R%d]\n", $rgd, $rgn, $rgm ;
   }
   # Rd = [Rn + Rm]C
   elsif ( ( $opcode & 0xfe00 ) == 0x5600 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "R%d = [R%d + R%d]C\n", $rgd, $rgn, $rgm ;
   }
   # Rd = [Rn + Rm]W
   elsif ( ( $opcode & 0xfe00 ) == 0x5a00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "R%d = [R%d + R%d]W\n", $rgd, $rgn, $rgm ;
   }
   # Rd = [Rn + Rm]S
   elsif ( ( $opcode & 0xfe00 ) == 0x5e00 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "R%d = [R%d + R%d]S\n", $rgd, $rgn, $rgm ;
   }
   # Rd = [Rn + Rm]L
   elsif ( ( $opcode & 0xfe00 ) == 0x5800 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "R%d = [R%d + R%d]L\n", $rgd, $rgn, $rgm ;
   }
   # [Rn + u5] = Rd
   elsif ( ( $opcode & 0xf800 ) == 0x7000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "[R%d + %d] = R%d\n", $rgn, $u5, $rgd ;
   }
   # [Rn + u5]W = Rd
   elsif ( ( $opcode & 0xf800 ) == 0x8000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "[R%d + %d]W = R%d\n", $rgn, $u5, $rgd ;
   }
   # [Rn + u5]L = Rd
   elsif ( ( $opcode & 0xf800 ) == 0x6000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = 0 ;
      $u5  = ( $opcode & 0x07c0 ) / 0x40 ;
      printf "[R%d + %d]L = R%d\n", $rgn, $u5, $rgd ;
   }
   # [Rn + Rm] = Rd
   elsif ( ( $opcode & 0xfe00 ) == 0x5400 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "[R%d + R%d] = R%d\n", $rgn, $rgm, $rgd ;
   }
   # [Rn + Rm]W = Rd
   elsif ( ( $opcode & 0xfe00 ) == 0x5200 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "[R%d + R%d]W = R%d\n", $rgn, $rgm, $rgd ;
   }
   # [Rn + Rm]L = Rd
   elsif ( ( $opcode & 0xfe00 ) == 0x5000 )
   {
      $pc = $pc + 2;
      $rgd = ( $opcode & 0x0007 ) ;
      $rgn = ( $opcode & 0x0038 ) / 0x8 ;
      $rgm = ( $opcode & 0x01c0 ) / 0x40 ;
      $u5  = 0 ;
      printf "[R%d + R%d]L = R%d\n", $rgn, $rgm, $rgd ;
   }
   # Rn - u8
   elsif ( ( $opcode & 0xf800 ) == 0x2800 )
   {
      $pc = $pc + 2;
      $rgd = 0 ;
      $rgn = ( $opcode & 0x0700 ) / 0x100 ;
      $rgm = 0 ;
      $u8  = ( $opcode & 0x00ff ) ;
      printf "R%d + %d\n", $rgn, $u8 ;
   }
   # Rn - Rm
   elsif ( ( $opcode & 0xff00 ) == 0x4500 )
   {
      $pc = $pc + 2;
      $rgd = 0 ;
      $rgn = ( $opcode & 0x80 ) / 0x10 + ( $opcode & 0x7 ) ;
      $rgm = ( $opcode & 0x078 ) / 0x8 ; ;
      $u8  = 0 ;
      printf "R%d - R%d\n", $rgn, $rgm ;
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


# : ファイルオブジェクト_閉じる

   close $fh;


