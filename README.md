# QMLaTex
QML Wrapper for creating Latex Documents

QMLaTex provides an interface for writing structured Documents in QML which can be compiled to LaTex code and generate LaTex Documents. QML Items are provided via C++ interface and are exposed to the QML context. See [src/qml/MyLatexDocument.qml] [PlDb] how to define the Document in QML. The provided `LatexCompiler` Item takes the document as property and generates a PDF file. Note you need to have installed a valid LaTex distribution (including needed packages), as in the background LaTex binaries are called to generate the document. The software was tested with the MikTex environment.

#### Example QML
```qml
Item {
    LatexDocument {
	LatexSection {
		title: "{The First Section}"
	}
	LatexCodeBlock {
		code: "Here comes the text for the first section"
	}
	LatexSubSection {
        title: "{The Sub Section}"
	}
	LatexCodeBlock {
		code: "Here comes the text for the first section"
	}
}
```
#### QML Items Provided by the C++ Interface:
  
  - `LatexDocument` - The top level item for each document
  - `LatexCodeBlock` - The document is build up by a set of (nested) LaTex code blocks
  - `LatexModelMapper` - An Item for generating data out of Qt models
  - `LatexCompiler` - A utility item for generating LaTex Documents 
  - `LatexSyntaxHighlighter` - A utility item for LaTex synthax highlighting

#### QML Convenience Items
The folder [src/qml/latex] [PlDb] contains defined convenience items for reuse. 

  - `LatexSection` - Defines a section
  - `LatexSubSection` - Defines a subsection
  - `LatexTable` - Defines a table with an Qt model as input
  - ...