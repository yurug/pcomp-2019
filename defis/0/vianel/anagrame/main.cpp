//
//  main.cpp
//  anagrame
//
//  Created by ebourefe vianel on 09/01/2017.
//  Copyright © 2019 ebourefe. All rights reserved.
//

#include <iostream>
#include <algorithm>
#include <string>
#include <fstream>
#include <vector>

using namespace std;





bool isAnagrame(std::string a,std::string b)
{
    int i;
    if(a.length()!=b.length())
       
        return false;
    sort(a.begin(),a.end());
    sort(b.begin(),b.end());
    for(i=0;i<a.length();i++)
    {
       if(a[i]!=b[i])
        return false;
    }
    
    return true;
}



int main(int argc, const char * argv[]) {
 
   
   
 ifstream fichier("r.txt", ios::in);  // on ouvre en lecture
    
    if(fichier)
    {
        string ligne;
        while(getline(fichier, ligne))  // tant que l'on peut mettre la ligne dans "contenu"
        {
            if(isAnagrame("marion", ligne))
            {
                
                cout << ligne << endl;  // on l'affiche
            }
            else
            {
                std::cout << "c'est faux \n";
            }
            
        }
    }
    

       else
        cerr << "Impossible d'ouvrir le fichier !" << endl;
    
    return 0;
}
