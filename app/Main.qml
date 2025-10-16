/*
 * Copyright (C) 2025 Pierre Parent
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import Morph.Web 0.1
import QtWebEngine 1.9
import Qt.labs.settings 1.0
import QtSystemInfo 5.5
import Ubuntu.Components.ListItems 1.3 as ListItemm
import Ubuntu.Content 1.3


MainView {
  id: mainView
  
  property var appID: "chromiumpdf.pparent";
  property var hook: "chromiumpdf";  
  property var localStorage: "/home/phablet/.cache/chromiumpdf.pparent/QtWebEngine";  
  
  
  property int lastUnreadCount: -1;
  property var lastNotifyTimestamp: 0;  
  property var importPage


  objectName: "mainView"
  //theme.name: "Ubuntu.Components.Themes.SuruDark"
  applicationName: "chromiumpdf.pparent"
  backgroundColor : "transparent"


 // property list<ContentItem> importItems

  
  ScreenSaver {
    id: screenSaver
    screenSaverEnabled: !(Qt.application.active)
  }
  

  Component.onCompleted: {
        // 1) si l'app a été lancée par un transfer déjà présent
        if (ContentHub.incoming) {
            handleIncoming(ContentHub.incoming)
        }
        else
        {
        importPage = mainPageStack.push(Qt.resolvedUrl("ImportPage.qml"),{"contentType": ContentType.All, "handler": ContentHandler.Source})
        importPage.imported.connect(function(fileUrl) {
              mainPageStack.pop(importPage)
              loadPdf(fileUrl);
          })
        }
    }

    // 2) Aussi écouter les signals du ContentHub au runtime
    Connections {
        target: ContentHub
        onImportRequested: function(transfer) {
            handleTransfer(transfer)
        }
    }

  function loadPdf(url) {
    // Vérifie que l'URL se termine par .pdf (insensible à la casse)
    if (url && url.toString().toLowerCase().endsWith(".pdf")) {
        webview.url = url;
    } else {
       toast.show("Not a pdf file");
       importPage = mainPageStack.push(Qt.resolvedUrl("ImportPage.qml"),{"contentType": ContentType.All, "handler": ContentHandler.Source})
       importPage.imported.connect(function(fileUrl) {
              mainPageStack.pop(importPage)
              loadPdf(fileUrl);
          })
    }
  }

    function handleIncoming(incoming) {
            var transfer = incoming.transfers[0] 
            handleTransfer(transfer)
            
    }
    
     function handleTransfer(transfer) {
       var item = transfer.items[0]
        loadPdf(item.url)
        if (importPage)
          mainPageStack.pop(importPage)
    }   
  PageStack {
    id: mainPageStack
    anchors.fill: parent
    
    Component.onCompleted: 
    {mainPageStack.push(pageMain)
    }


    Page {
      id: pageMain
      anchors.fill: parent
      
      //Webview-----------------------------------------------------------------------------------------------------
      WebEngineView {
        id: webview
        anchors{ fill: parent }
        focus: true
        settings.pluginsEnabled: true
       
        anchors {
          fill:parent
        }
       url: ""
      
        onNewViewRequested: {
            request.action = WebEngineNavigationRequest.IgnoreRequest
            if(request.userInitiated) {
                Qt.openUrlExternally(request.requestedUrl)
            }
        }
        onFeaturePermissionRequested: {
	    grantFeaturePermission(securityOrigin, feature, true);
        }

      } //End webview--------------------------------------------------------------------------------------------
      
    }
    

  }
  
        Toast {
      id: toast
      }  
}
