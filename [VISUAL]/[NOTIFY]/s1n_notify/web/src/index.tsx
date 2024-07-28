import * as React from "react";
import * as ReactDOM from "react-dom/client";
import './index.css';
import App from './components/App';
import {VisibilityProvider} from "./providers/VisibilityProvider";
import { ChakraProvider, ColorModeScript } from "@chakra-ui/react";
import { createStandaloneToast } from "@chakra-ui/toast";

const { ToastContainer, toast: StandaloneToast } = createStandaloneToast();

const container = document.getElementById("root");
if (!container) throw new Error("Failed to find the root element");
const root = ReactDOM.createRoot(container);

root.render(
  <React.StrictMode>
      <VisibilityProvider>
          <ChakraProvider>
                <ColorModeScript />
                    <App />
                <ToastContainer /> // Access standalone toasts globally...
            </ChakraProvider>
      </VisibilityProvider>
  </React.StrictMode>
);

export { StandaloneToast };