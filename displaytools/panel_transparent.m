function panel_transparent(hPanel)
jPanel = hPanel.JavaFrame.getPrintableComponent;  % hPanel is the Matlab handle to the uipanel
jPanel.setOpaque(false)
jPanel.getParent.setOpaque(false)
jPanel.getComponent(0).setOpaque(false)
jPanel.repaint