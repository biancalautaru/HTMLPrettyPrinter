# HTMLPrettyPrinter

1. **[Descrierea problemei](#1-descrierea-problemei)**
2. **[Descrierea soluției](#2-descrierea-soluției)**
3. **[Dificultăți întâmpinate](#3-dificultăți-întâmpinate)**
4. **[Rezultate experimentale](#4-rezultate-experimentale)**

## 1. Descrierea problemei

> Cerință: Scrieți un program (script) shell care primește ca input un fișier HTML și îl
formatează astfel încât sa reflecte vizual structura ierarhică și nivelul de imbricare
al resurselor folosite prin indentarea corespunzătoare a tag-urilor și stringurilor.

Proiectul are ca scop formatarea unui fișier HTML pentru a sugera vizual structura
ierarhică a elementelor sale. Pentru a obține o indentare corectă, se presupune că
fișierul respectă structura corectă a unui fișier HTML (tag-urile respectă ordinea de
deschidere și închidere, denumirile tag-urilor sunt corecte etc.). Indentarea
corespunzătoare îmbunătățește lizibilitatea codului, evidențiind relațiile dintre tag-
uri.

## 2. Descrierea soluției

1. Se verifică dacă există fișierul oferit ca parametru pentru script.
2. Se creează un fișier gol pentru output.
3. Se parcurge fișierul HTML caracter cu caracter și se apelează o funcție care afișează în terminal o bară de progres.
4. Se verifică dacă începe un tag și de ce tip (normal / singleton – are doar tag de deschidere / inline – care să nu fie afișat pe rând nou).
   1. Când se ajunge la un tag de deschidere, nivelul de indentare curent crește cu 1.
   2. Când se ajunge la un tag de închidere, nivelul de indentare curent scade cu 1.
   3. Se afișează în fișierul de output un newline (dacă nu este tag inline), un număr de tab-uri egal cu nivelul de indentare și tag-ul.
5. Se verifică dacă s-a ajuns la conținutul text din interiorul unui tag, caz în care este afișat numărul corespunzător de tab-uri, apoi textul.
6. La finalul parcurgerii fișierului, se afișează în terminal numele fișierului de output.

## 3. Dificultăți întâmpinate

- La afișarea textului din interiorul tag-ului <a> în formatul:
  
	```html
	<a href="#section">
		text
	</a>
	```

	textul este afișat diferit în browser față de formatul:

	```html
	<a href="#section">text</a>
 	```

	și am ales a doua variantă, pentru a păstra identic modul în care arată în browser
	fișierul oferit pentru formatare.

- Pentru fișierele mai mari, rularea scriptului durează mai mult timp. Pentru a ști
aproximativ cât de mult din fișier a fost procesat la un moment dat, am adăugat o bară
de progres ce apare în terminal:

	![image](https://github.com/user-attachments/assets/01507dc9-e772-4642-884e-c99fdc21b051)

	![image](https://github.com/user-attachments/assets/c9835b94-1971-4f20-8e13-034c10aa1356)

	![image](https://github.com/user-attachments/assets/8ef4b71a-791c-47e6-85f9-c22691b2ee74)


## 4. Rezultate experimentale

- Dacă se oferă ca parametru un fișier inexistent:

	![image](https://github.com/user-attachments/assets/1dd27077-0a1a-4be2-9de9-4d906c6dd919)

- Formatarea fișierului `test.html`:

	![image](https://github.com/user-attachments/assets/e2a9db4d-ac5b-45f1-a18e-c8a859a1acd8)

	![image](https://github.com/user-attachments/assets/9e61c069-7bec-4741-a7be-44853bc29040)

	![image](https://github.com/user-attachments/assets/7cdaa506-dc86-4adf-af4f-e4dd1e004825)

- Formatarea fișierului `lab2.html`, realizat pentru materia Tehnici Web:

	![image](https://github.com/user-attachments/assets/410963bd-35e6-4398-92b3-56a92a20649b)

	![image](https://github.com/user-attachments/assets/c0e4bc25-abb6-4e50-95d8-302074c4000d)

	![Picture1](https://github.com/user-attachments/assets/2260980f-6e63-4ba6-8065-eb4f95b8c4a4)

	![Picture2](https://github.com/user-attachments/assets/84d3a6d9-fb6e-4bd6-b3d0-11d1aecf98e8)
