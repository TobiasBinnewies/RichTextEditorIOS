# RichTextEditorIOS
A rich text editor for IOS written in Swift using SwiftUI and UIKit 

With this editor the user can modify text styles like bold, italic, underline and strikethrouht and change the font style
(default apple styles like body, large title, caption, ...).
Additionally there is a list option (ordered and unordered).

This project is heavily inspired by the Proton-Project (https://github.com/rajdeep/proton; rajdeep:main). 

Problems:
- On list style change not working if different ListItem-Objects are in use
- On list style change not correctly changing the symbols (LayoutManager problem)
