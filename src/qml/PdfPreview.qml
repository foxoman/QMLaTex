import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.2


/**
 * @brief preview for a pdf docuument
 * @details One page is shown.
 * There are 2 buttons for next and previous page.
 * Pdf Preview handles all latex compiler signals.
 */
Rectangle {
	property QtObject compiler
	
	color: "#525659"
	property int margins: 20
	
	property int numOfPages: {
		if (compiler != null)
			return compiler.numOfPages;
		else
			return 0;
	}

	property int currentPage: 1
	
    /// @brief move to the document begin
	function moveToBegin() {
		console.log("PdfPreview.moveToBegin");
		currentPage = 1;
	}

    /// @brief mode to the document end
	function moveToEnd() {
		console.log("PdfPreview.moveToEnd");
		currentPage = numOfPages;
	}
	
	//
	// internal
	//
	id: self
	
    Button {
		id: nextPage
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: 20
		anchors.rightMargin: 40
		z: 1
        text: "Next Page"
        visible: numOfPages > 1
        enabled: currentPage < numOfPages
		
		onClicked: {
			console.log("currentPage", currentPage, 
						"numOfPages", numOfPages);
					
			if (numOfPages > currentPage)
				currentPage++;
		}
	}

    Button {
		id: previousPage
		anchors.top: parent.top
		anchors.topMargin: 20
		anchors.right: nextPage.left
		z: 1
        text: "Prev Page"
        visible: numOfPages > 1
        enabled: currentPage > 1

		onClicked: {
			if (currentPage > 1)
				currentPage--;
		}
	}

	ScrollView {
		anchors.fill: parent
		id: scrollView
		verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
		horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
		
		onWidthChanged: {
			computeImageWidth();
		}
		
		function computeImageWidth() {
			var sourceWidth = preview.sourceSize.width;
			var sourceHeight = preview.sourceSize.height;

			if ((viewport.width + self.margins*2) < sourceWidth) {
				preview.width = viewport.width - (self.margins*2);
				preview.x = self.margins;
			}
			else {
				preview.width = sourceWidth;
				preview.x = (viewport.width - sourceWidth)/2;
			}
		}
		
		Image { 
			id: preview
			y: self.margins
			
			fillMode: Image.PreserveAspectFit
			cache: false
            source: "../res/png/close.png"
			mipmap: false
			smooth: true
			
			ShaderEffect {
				id: theEffect
				width: parent.width
				height: parent.height

				property variant source: preview

				// maus position in mipmap style von 0 bis 1
				property point mouse: {
					if (!mausi.containsMouse)
						return Qt.point(0.0,0.0);
					else {
						var x = mausi.mouseX/width;
						var y = mausi.mouseY/height;
						return Qt.point(x, y);
					}
				}

				// sollen wir es tun oder nicht
				property bool magnify: {
					return mausi.containsMouse && mausi.containsPress;
				}
				
				// seitenverhaeltnis breiet zu hoehe 
				property real aspectRatio: {
					return width/height;
				}
				
				fragmentShader:
					"uniform lowp float qt_Opacity;" +
					"uniform highp vec2 mouse;" +
					"uniform bool magnify;" +
					"uniform lowp float aspectRatio;" +
					"uniform sampler2D source;" +
					"varying highp vec2 qt_TexCoord0;" +
					"void main() {" +
					"    float radius = 0.2;" +
					"	 float x = mouse.x - qt_TexCoord0.x;" +
					"	 float y = (mouse.y - qt_TexCoord0.y) / aspectRatio;" +
					"    vec2 xy = mouse - qt_TexCoord0;" +
					"    float dist = sqrt(x*x + y*y);" +
					"    if (!magnify || dist > radius) {" +
					"        gl_FragColor = texture2D(source, qt_TexCoord0);" +
					"    } else {" +
					"       float xdist = qt_TexCoord0.x - mouse.x ;" +
					"       float xNew = xdist * 0.1 / radius;" +
					"       float ydist = qt_TexCoord0.y - mouse.y ;" +
					"       float yNew = ydist * 0.1 / radius;" +
					"       gl_FragColor = texture2D(source, vec2(mouse.x + xNew, mouse.y + yNew));" +
					"    }" +
					"}"
				// end fragmentShader
			} // shadereffect

            MouseArea {
                id: mausi
				cursorShape: Qt.CrossCursor
				anchors.fill: parent
            }
		} // image
	} // scrollview

	AnimatedImage { 
		anchors.centerIn: scrollView
		z: 10
		source: "../res/spinner.gif";
		visible: (compiler != null) ? compiler.busy : null;
	}
	
	Component.onCompleted: {
		if (compiler != null) {
			connectCompiler();
		}
	}
	
	function connectCompiler() {
		console.log("PdfPreview.connectCompiler: compiler=", compiler);
		compiler.startCreatingPreviews.connect(moveToBegin);
		compiler.previewPageGenerated.connect(onPreviewPageGenerated);
	}
	
	function reloadPage() {
		// workaround, dass image item wirklich das bild neu laedt
		preview.source = "../res/png/close.png";
		preview.source = "image://previews/pdfdoc" + currentPage;
		scrollView.computeImageWidth();
	}
	
	function onPreviewPageGenerated(page) {
		console.log("PdfPreview.onPreviewPageGenerated: page=", page);
		
		if (currentPage != page) 
			return
		else
			reloadPage();
	}
	
	onCurrentPageChanged: {
		console.log("PdfPreview.onCurrentPageChanged:", currentPage);
		preview.source = "image://previews/pdfdoc" + currentPage;
	}
}
