# Házi feladat

## Chatty iOS App

A Chatty nevű alkalmazás ahogy a neve is leírja egy chat alkalmazás. Funkciók szempontjából hasonlóan működik mint az ismert chat alkalmazások (Messenger, Viber stb.), kivéve, hogy nincs minden azokban megtalálható funkció implementálva.

## Felépítése

Az alkalmazás több View-ból épül fel. Indulásakor megjelenik egy Splash screen. Ezután bejön egy oldal, ahol választani lehet a bejelentkezés és a regisztráció között.
Ezek ismeretében van egy bejelentkező és egy regisztrációs ablak. Bejelentkezés illetve regisztráció után megjelenik a főképernyő, ahol egy TabBarController-en tudunk navigálni a felhaszálók, a chat-ek illetve a saját profilunk között.
Ha egy felhasználóra érintünk, megjelenik a chat ablak.

## Regisztráció és Bejelentkezés

### Regisztráció

Ha egy felhasználó szeretne regisztrálni az alkalmazásba ahhoz 3 adatot kell megadnia: Felhasználónév, Email cím, Jelszó. Emellett beállíthat magának egy profilképet ha megérinti az ablakon lévő képet.
Miután beírta az adatokat a regisztráció gombra nyomva az alkalmazás regisztrálja a felhasználót a Firebase segítségével, feltölti oda az adatait és profilképét, majd elnavigálja a főképernyőre.

![](https://github.com/kovacsmarci96/Chatty_iOS/blob/master/registerScreen.png)

### Bejelentkezés

Ha a felhasználónak már van egy profilja, akkor a bejelentkező ablakon tud oda bejelentkezni. Itt az email címét és jelszavát kell megadnia. Van egy lehetőség, hogy az alkalmazás mentse el a jelszavát így nem kell neki mindig beírnia azt. Ha véletlenül elfelejtette volna a jelszavát, akkor az ablak alján lévő "Forgot password?" gombra érintve tudja megváltoztatni a jelszavát.
Ha egy felhasználó be van jelentkezve, de az alkalmazást bezárta, akkor az app újraindulásakor egyből a fő képernyőre navigál az alkalmazás.

## Főképernyő

Sikeres regisztráció után a felhasználó elé tárul a főképernyő. Itt három oldal között lépkedhet:
1. Beszélgetések
2. Felhasználók
3. Profil
A főképernyő tetején lévő Navigációs részben megjelenik a bejelentkezett felhasználó neve és profilképe. 
Ezek mellett bal oldalon van a kijelentkező gomb, és ez a navigációs rész változhat, attól függően, hogy melyik abalakon van a felhasználó.

![](https://github.com/kovacsmarci96/Chatty_iOS/blob/master/mainScreen.png)

### Felhasználók

Ezen a képernyőn egy táblában jellenek meg a regisztrált felhasználók. Megjelenik a hozzájuk tartozó profilkép, felhasználónév és email cím. Ha a bejelentkezett felhasználó megérint egy felhasználót elkezdhet vele chat-elni.

### Beszélgetések

Ezen a képernyőn megjelennek azon felhasználók akivel a bejelentkezett felhasználó már csevegett korábban. Hasonlóan mint a felhasználók ablakon itt is megjelenik az adott felhasználó profilképe, neve és az utolsó üzenet.
Az utolsó üzenet négy féle lehet:
1. Ha ez egy szöveges üzenet volt akkor megjelenik a küldött szöveg.
2. Ha ez egy képüzenet volt akkor az "Image message" szöveg jelenik meg.
3. Ha ez egy videóüzenet volt akkor a "Video message" szöveg jelenik meg.
4. Ha egy helyzet üzenet volt akkor a "Location message" szöveg jelenik meg.

### Profil

Itt megváltozik a navigációs rész mivel megjelenik a szerkesztés gomb. Ha erre érint a felhasználó, akkor tudja megváltoztatni az adatait.
Változtathatja a profilképét, felhasználónevét, illetve megadhatja a telefonszámát.
Ha mindennel végzett a "Save" gombbal tud menteni.

## Chat ablak

Ez a rész az alkalmazás "szíve". Az ablak alsó részében tudja beírni a felhasználó az üzenetét. Ha nem szöveges üzenete szeretne küldeni, akkor lehetősége van választani ugyanitt 3 funkcióból.
1. Kamera használata: Ekkor megjelenik a kamera és a felhasználó által készített képet tudja elküldeni ismerősének.
2. Fotókönyvtár: Ekkor a felhasználó választhat a képei illetve videói közül és ezek közül lesz elküldve a kiválasztott.
3. Helyzet: Ekkor a felhasználó pozíciója lesz elküldve.

Miután elküldte az adott üzenetet, megfog jelenni az ablak közepén lévő felületen. Szöveges üzenet esetén a saját üzenetei kék buborékban vannak, míg a csevegőtárstól érkezett üzenetek szürkében.
Ha egy kép üzenetet küldött akkor a kép fog megjelenni, erre érintve ki lehet nagyítani azt. 
Ha videót küldött az is megfog jelenni, a lejátszás gombra érintve lefog játszódni kicsiben a videó.
Ha pedig egy helyzetet küldött, akkor megfog jelenni egy kis térkép, megjelölve a felhasználó helyzetét. A térképen a kis jelölésre érintve, megnyílik a beépített térképek alkalmazás, ahol megjelenik a felhasználó helyzete, címe, neve és ha megvan adva telefonszáma az is.

![](https://github.com/kovacsmarci96/Chatty_iOS/blob/master/chatScreen.png)

## Adatok tárolása és betöltése

Az alkalmazás a Firebase-t használja backend-ként. Itt tárolódnak a regisztrált felhasználók, az adataik, ide töltődnek fel a különböző képek és videók, illetve itt tárolódnak az üzenetek is.
A Firebase-el egyszerűen le lehet tölteni a szöveges erőforrásokat, a képek és videók letöltését URLSession végzi a Firebase-ben tárolt URL-ek alapján.



    

    





[Register]:  /Chatty/registerScreen.png
[Main]:  /Chatty/mainScreen.png
[Chat]:  /Chatty/chatScreen.png

