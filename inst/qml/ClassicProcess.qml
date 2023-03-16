
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
		columns: 1

		// VariablesList
		// {
		// 	name: "assignedCovariates"
		// 	source: ["covariates", "factors"]
		// 	listViewType: JASP.AssignedVariables
		// 	preferredHeight: 100 * preferencesModel.uiScale
		// 	draggable: false

		// 	rowComponent: Row
		// 	{
		// 		Label
		// 		{
		// 			text: dependent
		// 		}
		// 		DropDown
		// 		{
		// 			name: "mode"
		// 			indexDefaultValue: 0
		// 			values:
		// 				[
		// 				{ label: qsTr("Additive"), value: "additive"				},
		// 				{ label: qsTr("Multiplicative"), value: "multiplicative"	},
		// 			]
		// 		}
		// 	}
		// }

				// spacing: 0 * preferencesModel.uiScale
				RowLayout
				{
					Label { text: qsTr("Independent"); }
					Label { text: qsTr("Dependent")}
					Label { text: qsTr("Mediator")}
					Label { text: qsTr("Moderator")}
				}

				ComponentsList
				{
					name: "seasonalities"
					preferredWidth: form.width
					rowComponent: RowLayout
					{
						Row
						{
							// Layout.preferredWidth: 100 * preferencesModel.uiScale
							// spacing: 4 * preferencesModel.uiScale

							DropDown
							{
								name: 'independent'
								source: ['covariates', 'factors']
							}
						}
						Row
						{
							DropDown
							{
								name: 'dependent_mediators'
								source: ['dependent']
								Component.onCompleted: {
									console.log("Completed Running!")
								}
							}
						}
						Row
						{
							DropDown
							{
								id: type
								name: 'type'
								values: ['Mediator', 'Moderator']
							}
						}
						Row
						{
							DropDown
							{
								id: meds
								name: 'mediators_moderators'
								source: ['covariates', 'factors']
							}
						}
					}
				}
	}
}
