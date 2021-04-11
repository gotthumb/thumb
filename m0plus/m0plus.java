// Copyright 2021, gotthumb 
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// OpenJDK Runtime Environment (build 1.8.0_252-b09)
// OpenJDK 64-Bit Server VM (build 25.252-b09, mixed mode)
//
// thumb emulator r0p0-alpha
//

import java.io.*;

// 
public class m0plus {
   public static void main( String args[]){

      BufferedInputStream bdata = null;

      int tmp = 0 ;

      try {

         bdata = new BufferedInputStream(new FileInputStream("../test/thumbcode1.bin"));

         while((tmp=bdata.read()) != -1 ){
            System.out.println(tmp);
         }
   
         bdata.close();

      } catch (IOException e){
         e.printStackTrace();
      }
   }
}



