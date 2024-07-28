import { Box, Flex, Text } from "@chakra-ui/react";
import { AiOutlineCloseCircle } from "react-icons/ai";
import * as Icons from "react-icons/md";
import { StandaloneToast } from "../..";

interface ToastParamTypes {
	title: string;
	message: string;
	type: string;
	theme: "white" | "colorful";
	position: "top-left" | "top-right" | "bottom-left" | "bottom-right";
	duration: number;
	icon: string;
	color: string;
}

const ShowToast = ({ title, message, type, theme, position, duration, icon, color }: ToastParamTypes) => {
	StandaloneToast({
		duration,
		position,
		isClosable: true,
		render: ({ onClose }) => {
			const CustomMdIcon = () => {
				// @ts-ignore
				const Icon = Icons[icon];
				if (!Icon) return <p>Icon not found!</p>;

				return <Icon />;
			};

			return (
				<Flex
					w="330px"
					minH="70px"
					position="relative"
					justifyContent="flex-start"
					alignItems="flex-start"
					gap="12px"
					py="20px"
					px="13px"
					pl={theme === "white" ? "29px" : "13px"}
					color={theme === "white" ? "black" : "white"}
					bg={theme === "white" ? "white" : color}
					borderRadius="4px"
					boxShadow="md"
				>
					{theme === "white" && (
						<Box
							width="5px"
							borderRadius="5px"
							backgroundColor={color}
							position="absolute"
							top="8px"
							bottom="8px"
							left="8px"
						/>
					)}

					<Box
						as="button"
						width="32px"
						height="32px"
						sx={{
							"& svg": {
								width: "100%",
								height: "100%",
								fill: theme === "white" ? color : "white",
							},
						}}
					>
						<CustomMdIcon />
					</Box>
					<Box>
						<Text fontSize="16px" fontWeight="500" lineHeight="16.4px" mb="1px">
							{title}
						</Text>
						<Text
							maxW="220px"
							fontSize="13px"
							color={theme === "white" ? "#999999" : "white"}
							lineHeight="12.9px"
						>
							{message}
						</Text>
					</Box>
				</Flex>
			);
		},
	});
};

export default ShowToast;
