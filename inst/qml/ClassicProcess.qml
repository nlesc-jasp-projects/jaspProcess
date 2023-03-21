
import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls

Form
{

	// Formula
	// {
	// 	lhs: "dependent"
	// 	rhs: [{ name: "modelTerms", extraOptions: "isNuisance" }]
	// 	userMustSpecify: "covariates"
	// }

	VariablesForm
	{

		AvailableVariablesList { name: "allVariablesList" }
		AssignedVariablesList 
		{
			name:				"dependent"
			title:				qsTr("Dependent Variable")
			suggestedColumns:	["scale"]
			singleVariable:		true
		}
		AssignedVariablesList
		{
			name:			"covariates"
			title:			qsTr("Covariates")
			allowedColumns:	["ordinal", "scale"]
		}
		AssignedVariablesList
		{
			name:			"factors"
			title:			qsTr("Factors")
			allowedColumns:	["ordinal", "nominal", "nominalText"]
		}
	}

	Section
	{
		title: qsTr("Models")
		columns: 2

		TabView
		{
			id:					models
			name:				"processModels"
			maximumItems:		10
			newItemName:		qsTr("Model 1")
			optionKey:			"name"

			content: Group
			{
				RadioButtonGroup
				{
					name: "inputType"
					title: qsTr("Input type")
					radioButtonsOnSameRow: true
					columns: 3

					RadioButton{
						id: variables
						value: "inputVariables"
						label: qsTr("Variables")
						checked: true
					}
					RadioButton{
						id: modelNumber
						value: "inputModelNumber"
						label: qsTr("Model number")
					}
					RadioButton{
						id: syntax
						value: "inputSyntax"
						label: qsTr("Syntax")
					}
				}

				Group
				{
					visible: variables.checked

					RowLayout
					{
						Label { text: qsTr("Independent"); }
						Label { text: qsTr("Dependent")}
						Label { text: qsTr("Mediator")}
						Label { text: qsTr("Moderator")}
					}

					ComponentsList
					{
						name: "processRelationships"
						
						preferredWidth: models.width
						rowComponent: RowLayout
						{
							Layout.columnSpan: 4
							DropDown
							{
								name: 'processIndependent'
								source: ['covariates', 'factors']
							}
							DropDown
							{
								name: 'processDependent'
								source: ['dependent']
							}							
							DropDown
							{
								name: 'processType'
								values: ['Mediator', 'Moderator', 'Confounder']
							}
							DropDown
							{
								name: 'processMediatorModerator'
								source: ['covariates', 'factors']
							}
						}
					}
				}

				DropDown
				{
					name: "modelNumber"
					label: qsTr("Model number")
					values: [1, 2, 3, 4, 5]
					visible: modelNumber.checked
				}

				TextArea 
				{
					name: "syntax"
					width: models.width
					textType: JASP.TextTypeLavaan
					visible: syntax.checked
				}
			}
		}
	}

	Section
	{
		title: qsTr("Models 2")

		VariablesForm
		{
			preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
			AvailableVariablesList		{	name: "allVariablesList2";	source: ['covariates', 'factors'] }
			VariablesList
			{
				name:  "variablePairs"
				listViewType			: JASP.AssignedVariables
				dropMode				: JASP.DropReplace
				showElementBorder		: true
				columns					: 3
				showVariableTypeIcon	: false
			}
		}
	}
}
