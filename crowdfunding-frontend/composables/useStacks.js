import { connect } from "@stacks/connect";
import { StacksMainnet, StacksTestnet } from "@stacks/network";
import {
  callReadOnlyFunction,
  uintCV,
  stringUtf8CV,
} from "@stacks/transactions";
import { ref } from "vue"; // Assuming you're using Vue 3
import { useRuntimeConfig } from "#app"; // For Nuxt 3

export const useStacks = () => {
  const config = useRuntimeConfig();
  const userSession = ref(null);
  const network = ref(null);

  const initWallet = async () => {
    const session = new connect({
      appDetails: {
        name: "Crowdfunding App",
        icon: "/icon.png",
      },
    });
    userSession.value = session;
    network.value = new StacksTestnet(); // Use StacksMainnet() for production
  };

  const createCampaign = async (title, description, goal) => {
    if (!network.value) {
      throw new Error("Network not initialized. Call initWallet first.");
    }

    const functionArgs = [
      stringUtf8CV(title),
      stringUtf8CV(description),
      uintCV(goal * 1000000), // Convert STX to microSTX
    ];

    const options = {
      contractAddress: config.public.contractAddress,
      contractName: "crowdfunding",
      functionName: "create-campaign",
      functionArgs,
      network: network.value,
    };

    return await callReadOnlyFunction(options);
  };

  const getCampaign = async (id) => {
    if (!network.value) {
      throw new Error("Network not initialized. Call initWallet first.");
    }

    const options = {
      contractAddress: config.public.contractAddress,
      contractName: "crowdfunding",
      functionName: "get-campaign",
      functionArgs: [uintCV(id)],
      network: network.value,
    };

    return await callReadOnlyFunction(options);
  };

  return {
    userSession,
    initWallet,
    createCampaign,
    getCampaign,
  };
};
