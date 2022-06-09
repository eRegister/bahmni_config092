Bahmni.ConceptSet.FormConditions.rules = {


        //////////////////////////////////////////////////////////////////////////
        /////////////////////////// Tuberculosis - Intake Form ///////////////////
        /////////////////////////////////////////////////////////////////////////
        'Genotypic test type performed': function (formName, formFieldValues) {
                var genexpertTest = formFieldValues['Genotypic test type performed'];
                var conditions = { show: [], hide: [] };
                switch (genexpertTest) {
                        case "GeneXpert test type":
                                conditions.show.push("GeneXpert results");
                                conditions.hide.push("Line Probe Assay results");
                                break;

                        case "Line Probe Assay test type":
                                conditions.show.push("Line Probe Assay results");
                                conditions.hide.push("GeneXpert results");
                                break;
                        default:
                                conditions.hide.push("GeneXpert results", "Line Probe Assay results");
                }
                return conditions;
        },

        'TB Transfer in': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['TB Transfer in'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Transfer In") {
                        conditions.show.push("HIVTC, Transferred in from");
                } else {
                        conditions.hide.push("HIVTC, Transferred in from");
                }

                return conditions;
        },
                /**** AUTOFILL WEIGHT VALUES */
                'WEIGHT': function (formName, formFieldValues) {
                        var conditions = { assignedValues: [] , disable: [] };
                        if (formName == "Vitals" || formName == "HIV Treatment and Care Progress Template"){
                                conditions.assignedValues.push(
                                { field: "WEIGHT", 
                                  fieldValue : 
                                        {
                                           isAutoFill: true,
                                           scopedEncounter:"CurrentVisit",
                                           isFilledOnRetrospectiveMode: false,
                                           enableDefaultValue:false,
                                           enableEditAfterAutoFill: false
                                        }
                                });
                        }
                        return conditions;
                },
                
        'HTC, Patient type': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HTC, Patient type'];
                var conditions = { show: [], hide: [],   assignedValues: [] };
                if (conditionConcept == undefined){
                        conditions.hide.push("HEIGHT");
                        conditions.hide.push("WEIGHT");
                        conditions.hide.push("TB Status");
                        conditions.hide.push("Systolic Data");
                        conditions.hide.push("Diastolic Data");
                        conditions.hide.push("IMAM, MUAC");

                }else if (conditionConcept == "HTC, Patient") {
                        conditions.assignedValues.push( {
                                field: "HEIGHT", 
                                fieldValue : {
                                        isAutoFill: true,
                                        scopedEncounter:"latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue:false,
                                        enableEditAfterAutoFill: true
                                        }
                                });

                        conditions.show.push("HEIGHT");
                        conditions.show.push("WEIGHT");
                        conditions.assignedValues.push( {
                                field: "WEIGHT", 
                                fieldValue : {
                                        isAutoFill: true,
                                        scopedEncounter:"latestvisit",
                                        isFilledOnRetrospectiveMode: true,
                                        enableDefaultValue:true,
                                        enableEditAfterAutoFill: true
                                        }
                                });
                        conditions.show.push("TB Status");
                        conditions.show.push("Systolic Data");
                        conditions.show.push("Diastolic Data");
                        conditions.show.push("IMAM, MUAC");


                } else if(conditionConcept == "HTC, Buddy") {
                        conditions.hide.push("HEIGHT");
                        conditions.hide.push("WEIGHT");
                        conditions.hide.push("TB Status");
                        conditions.hide.push("Systolic Data");
                        conditions.hide.push("Diastolic Data");
                        conditions.hide.push("IMAM, MUAC");

                }

                return conditions;
        },


        'Phase of TB Treatment': function (formName, formFieldValues) {

                var result = formFieldValues['Phase of TB Treatment'];

                var conditions = { enable: [], disable: []};

                if (!result || result != 'Initial Treatment Phase') {

                        conditions.enable.push("TB Treatment outcome");

                } else {

                        conditions.disable.push("TB Treatment outcome");

                      //  conditions.disable.push("TB Action taken for treatment Failures and/or Drug resistant patients");

                }

                return conditions;

        },

        'Phenotypic Test type performed': function (formName, formFieldValues) {
                var phenotipicTest = formFieldValues['Phenotypic Test type performed'];
                var conditions = { show: [], hide: [] };
                if (phenotipicTest) {
                        conditions.show.push("Phenotypic Test Results (ZN or C)");
                } else {
                        conditions.hide.push("Phenotypic Test Results (ZN or C)");
                }
                return conditions;
        },


        'TB, HIV Status': function (formName, formFieldValues) {
                var result = formFieldValues['TB, HIV Status'];
                var conditions = { show: [], hide: [] };
                if (!result || result == 'New Negative' || result == 'Known Negative') {
                        conditions.hide.push("TB, HIV Management");
                } else {
                        conditions.show.push("TB, HIV Management");
                }
                return conditions;
        },


        'Site : P/EP': function (formName, formFieldValues) {
                var result = formFieldValues['Site : P/EP'];
                var conditions = { show: [], hide: [] };
                if (!result || result != 'Extra Pulmonary') {
                        conditions.hide.push("TB, Site of Extra-pulmonary TB");
                } else {
                        conditions.show.push("TB, Site of Extra-pulmonary TB");
                }
                return conditions;
        },

        'HIVTC, TB Screened': function (formName, formFieldValues) {
                var result = formFieldValues['HIVTC, TB Screened'];
                var conditions = { show: [], hide: [] };
                if (result == 'Yes') {
                        conditions.show.push("TB Status");
                } else {
                        conditions.hide.push("TB Status");
                }
                return conditions;
        },


        'HIVTC, Prior ART': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Prior ART'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Transfer In") {
                        conditions.show.push("HIVTC, Transferred in");
                        //conditions.hide.push("HIVTC, ART start date");
                } else {
                        conditions.hide.push("HIVTC, Transferred in");
                        //conditions.show.push("HIVTC, ART start date");
                }
                return conditions;
        },

        'Refer or Consult': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Refer or Consult'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Provide nutritional support or infant feeding") {
                        conditions.show.push("HIVTC, Nutritional products");
                } else {
                        //conditions.hide.push("HIVTC, Nutritional products");
                }
                return conditions;
        },


        'HTS, Referral': function (formName, formFieldValues) {
                var result = formFieldValues['HTS, Referral'];

                var conditions = { show: [], hide: [] };

                if (result == "Referred") {
                        conditions.show.push("HTC, Referred Facility");
                } else {
                        conditions.hide.push("HTC, Referred Facility");
                }
                return conditions;
        },


        /*--------------------------MCH Programme------------------------------*/
        'Delivery Note, Delivery location': function (formName, formFieldValues) {
                var DeliveryPlace = formFieldValues['Delivery Note, Delivery location'];

                if ((formName == "PostNatal Care Register") || (formName == "Delivery Information") || (formName == "Lesotho Obstetric Record")) {
                        var conditions = { assignedValues: [],show: [], hide: [] };

                        if ((DeliveryPlace == "Institutional Delivery") || (DeliveryPlace == "Home Delivery")) {
                                conditions.show.push("Mode of Delivery");
                        } else {
                                conditions.hide.push("Mode of Delivery");
                        }
                }
                if ((formName == "PostNatal Care Register") || (formName == "Delivery Information") ) {
                       
                        conditions.assignedValues.push({
                                field: "Delivery Note, Delivery location",
                                fieldValue: {
                                    isAutoFill: true,
                                    scopedEncounter: "latestvisit",
                                    isFilledOnRetrospectiveMode: true,
                                    enableDefaultValue: true,
                                    enableEditAfterAutoFill: true
                                }
                            });

                }

                return conditions;
        },
        'ANC, Parity': function (formName, formFieldValues) {
                var ANCGravida1 = formFieldValues['ANC, Gravida'];
                var ANCParity = formFieldValues['ANC, Parity'];
                var conditions = { show: [], hide: [], disable: [], enable: [] };
                if (formName == "ANC, Obstetric History") {

                        if (ANCParity >= ANCGravida1) {
                                alert("Parity should be less than Gravida");
                                conditions.disable.push("ANC, Alive");
                                conditions.disable.push("ANC, Number of Miscarriages");
                                return conditions;
                        }
                        if (ANCParity < ANCGravida1) {

                                conditions.enable.push("ANC, Alive");
                                conditions.enable.push("ANC, Number of Miscarriages");
                                return conditions;

                        }
                }

        },
        'ANC, Alive': function (formName, formFieldValues) {
                var ANCAlive = formFieldValues['ANC, Alive'];
                var ANCParity = formFieldValues['ANC, Parity'];
                var conditions = { show: [], hide: [], disable: [], enable: [] };
                if (formName == "ANC, Obstetric History") {

                        if (ANCAlive > ANCParity) {
                                alert("Children alive should be less or equal to number of parities");
                                conditions.disable.push("ANC, Number of Miscarriages");
                                return conditions;
                        }
                        if (ANCParity >= ANCAlive) {

                                conditions.enable.push("ANC, Number of Miscarriages");
                                return conditions;

                        }
                }

        },




        'ANC, Gravida': function (formName, formFieldValues) {
                var ANCGravida = formFieldValues['ANC, Gravida'];

                if (formName == "ANC, Obstetric History") {
                        var conditions = { show: [], hide: [], disable: [] };

                        if (ANCGravida < "2") {
                                conditions.hide.push("ANC, Alive");

                        }
                        if (ANCGravida < "2") {
                                conditions.hide.push("ANC, Number of Miscarriages");

                        }
                        if (ANCGravida < "2") {
                                conditions.hide.push("ANC, Parity");

                        } else {
                                conditions.show.push("ANC, Parity");
                                conditions.show.push("ANC, Alive");
                                conditions.show.push("ANC, Number of Miscarriages");
                        }
                }
                return conditions;
        },

        'ANC, Family Planning Ever Used': function (formName, formFieldValues) {
                var FPUsed = formFieldValues['ANC, Family Planning Ever Used'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (FPUsed == "Yes") {
                                conditions.show.push("ANC, Family Planning Method")
                                conditions.show.push("ANC, Date Family Planning Stopped");
                        }
                        else {
                                conditions.hide.push("ANC, Family Planning Method");
                                conditions.hide.push("ANC, Date Family Planning Stopped");
                        }
                }
                return conditions;
        },

        'ANC, History of STI': function (formName, formFieldValues) {
                var STIScreening = formFieldValues['ANC, History of STI'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (STIScreening == "Yes") {
                                conditions.show.push("STI Treated");
                                conditions.show.push("ANC, Date STI Treated");
                        }

                        else {
                                conditions.hide.push("STI Treated");
                                conditions.hide.push("ANC, Date STI Treated");
                        }
                }
                return conditions;
        },

        'ANC, History of Miscarriages': function (formName, formFieldValues) {
                var HistoryMis = formFieldValues['ANC, History of Miscarriages'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (HistoryMis == "Yes") {
                                conditions.show.push("ANC, When")
                                conditions.show.push("Delivery Note, Gestation period");
                                conditions.show.push("Dilation and Curettage");
                        }
                        else {
                                conditions.hide.push("ANC, When");
                                conditions.hide.push("Delivery Note, Gestation period");
                                conditions.hide.push("Dilation and Curettage");
                        }
                }
                return conditions;
        },

        'ANC, TB': function (formName, formFieldValues) {
                var TBHistory = formFieldValues['ANC, TB'];

                if (formName == "ANC, Previous Medical History") {
                        var conditions = { show: [], hide: [] };

                        if (TBHistory == "Yes") {
                                conditions.show.push("ANC, Year");
                                conditions.show.push("ANC, TB Treatment Completed");
                                conditions.show.push("ANC, Date Completed");
                        }
                        else {
                                conditions.hide.push("ANC, Year");
                                conditions.hide.push("ANC, TB Treatment Completed");
                                conditions.hide.push("ANC, Date Completed");
                        }
                }
                return conditions;
        },

        'Any Surgery': function (formName, formFieldValues) {
                var anySurgery = formFieldValues['Any Surgery'];
                var conditions = { show: [], hide: [] };

                if (anySurgery == "Yes") {
			conditions.show.push("ANC, Type of Surgery");
		} else if (!anySurgery || anySurgery != "Yes") {
			conditions.hide.push("ANC, Type of Surgery");
                }
                return conditions;
        },


        'ANC, Type of Surgery': function (formName, formFieldValues) {
                var typeOfSurgery = formFieldValues['ANC, Type of Surgery'];
                var conditions = { show: [], hide: [] };

                if (typeOfSurgery == "Surgery, Other") {
                        conditions.show.push("ANC, Surgery Specify");
                } else if (!typeOfSurgery || typeOfSurgery != "Surgery, Other") {
                        conditions.hide.push("ANC, Surgery Specify");
                }
                return conditions;
        },



        'ANC, Came together': function (formName, formFieldValues) {
                var MalePartner = formFieldValues['ANC, Came together'];

                if (formName == "Male Partner Involvement") {
                        var conditions = { show: [], hide: [] };

                        if (MalePartner == "Yes") {
                                conditions.show.push("ANC, Partner HIV Status");
                        }

                        else {
                                conditions.hide.push("ANC, Partner HIV Status");
                        }
                }
                return conditions;
        },

        'ANC, Tested as Couple': function (formName, formFieldValues) {
                var CoupleTest = formFieldValues['ANC, Tested as Couple'];

                if (formName == "LOR, PMTCT") {
                        var conditions = { show: [], hide: [] };

                        if (CoupleTest == "Yes") {
                                conditions.show.push("ANC, Partner HIV Status");
                        }

                        else {
                                conditions.hide.push("ANC, Partner HIV Status");
                        }
                }
                return conditions;
        },

        'ANC, Syphilis Screening Results': function (formName, formFieldValues) {
                var SyphilisScreening = formFieldValues['ANC, Syphilis Screening Results'];

                if (formName == "ANC, Investigations and Immunisations") {
                        var conditions = { show: [], hide: [] };

                        if (SyphilisScreening == "Reactive") {
                                conditions.show.push("ANC, Syphilis Screening Treatment");
                        }

                        else {
                                conditions.hide.push("ANC, Syphilis Screening Treatment");
                        }
                }
                return conditions;
        },

        'ANC, Ever Had Pap Smear': function (formName, formFieldValues) {
                var PapSmear = formFieldValues['ANC, Ever Had Pap Smear'];

                if (formName == "ANC, Gynaecological History") {
                        var conditions = { show: [], hide: [] };

                        if (PapSmear == "Yes") {
                                conditions.show.push("Results of Pap Smear");
                                conditions.show.push("ANC, Pap Smear Date");
                        }

                        else {
                                conditions.hide.push("Results of Pap Smear");
                                conditions.hide.push("ANC, Pap Smear Date");
                        }
                }
                return conditions;
        },

        'ANC, Type of Mother Baby Pack': function (formName, formFieldValues) {
                var MBPack = formFieldValues['ANC, Type of Mother Baby Pack'];

                if (formName == "ANC Register") {
                        var conditions = { show: [], hide: [] };

                        if (MBPack == "ANC, No Pack Given") {
                                conditions.hide.push("ANC, Adherence level to MBP");
                        } else {
                                conditions.show.push("ANC, Adherence level to MBP");
                        }
                }
                return conditions;
        },

        'Tested in PNC': function (formName, formFieldValues) {
                var TestedInPNC = formFieldValues['Tested in PNC'];

                if ((formName == "PostNatal Care Register") || (formName == "HIV Prevention, Care, and Treatment")) {
                        var conditions = { show: [], hide: [] };

                        if (TestedInPNC == "Positive") {
                                conditions.show.push("PMTCT, WHO clinical staging")
                                conditions.show.push("PNC, On ART Treatment");
                        } else {
                                conditions.hide.push("PMTCT, WHO clinical staging")
                                conditions.hide.push("PNC, On ART Treatment");
                        }
                }
                return conditions;
        },

        'ANC, Visit Types': function (formName, formFieldValues) {
                var AncVisits = formFieldValues['ANC, Visit Types'];

                if (formName == "ANC, ANC Program") {
                        var conditions = { show: [], hide: [], disable: [] };

                        if (AncVisits == "ANC, First Visit") {
                                conditions.show.push("Lesotho Obstetric Record")
                                conditions.hide.push("ANC Register");
                                //conditions.disable.push("ANC, Estimated Date of Delivery");
                                return conditions;
                        }
                        else if (AncVisits == "ANC, Subsequent Visit") {
                                conditions.show.push("ANC Register")
                                conditions.hide.push("Lesotho Obstetric Record");
                                return conditions;
                        }
                        else {
                                conditions.hide.push("Lesotho Obstetric Record")
                                conditions.hide.push("ANC Register");
                                return conditions;
                        }
                }

        },

        'PNC, HIV Status Known Before Visit': function (formName, formFieldValues) {
                var knownStatus = formFieldValues['PNC, HIV Status Known Before Visit'];

                if (formName == "LOR, PMTCT") {
                        var conditions = { show: [], hide: [] };

                        if (knownStatus == "Positive") {
                                conditions.hide.push("HTC, Final HIV status");
                        }

                        else {
                                conditions.show.push("HTC, Final HIV status");
                        }
                }
                return conditions;
        },

        'HTC, Final HIV status': function (formName, formFieldValues) {
                var finalStatus = formFieldValues['HTC, Final HIV status'];

                if (formName == "LOR, PMTCT") {
                        var conditions = { show: [], hide: [] };

                        if (finalStatus == "Negative") {
                                conditions.hide.push("ANC, CD4 Count Date")
                                conditions.hide.push("HIVTC, ART Regimen")
                                conditions.hide.push("PMTCT, ART start date");
                        }

                        else {
                                conditions.show.push("ANC, CD4 Count Date")
                                conditions.show.push("HIVTC, ART Regimen")
                                conditions.show.push("PMTCT, ART start date");
                        }
                }
                return conditions;
        },
        /*-----
                'HTC, Partner Testing and Counseling' : function (formName, formFieldValues) {
                 var coupleTest = formFieldValues['HTC, Partner Testing and Counseling'];

                if(formName == "LOR, PMTCT") {
                        var conditions = {show: [], hide: [], enable: [], disable: []};

                        if(coupleTest == "Yes") {
                                conditions.show.push("Partner HIV Status");
                        }
                        else {
                                conditions.hide.push("Partner HIV Status");

                        }
                        return conditions;
                              },
        -----*/

        'PNC, Initiated on Family Planning': function (formName, formFieldValues) {
                var InitiatedFP = formFieldValues['PNC, Initiated on Family Planning'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (InitiatedFP == "Yes") {
                                conditions.show.push("FP, Family Planning Method");
                        } else {
                                conditions.hide.push("FP, Family Planning Method");
                        }
                }
                return conditions;
        },




/*--------------------------------CERVICAL CANCER SCREENING----------------------------------------------------------*/

        'Cervical Cancer Screening': function (formName, formFieldValues) {
                var CancerScreened = formFieldValues['Cervical Cancer Screening'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (CancerScreened == "Yes") {
                                conditions.show.push("Cervical Cancer Assessment Method");
                        } else {
                                conditions.hide.push("Cervical Cancer Assessment Method")
                                conditions.hide.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                }
                return conditions;
        },
        'Cervical Cancer Screening Register': function (formName, formFieldValues, patient) {
                if (formName == "Cervical Cancer Screening Register") {
                        //var conditionConcept = formFieldValues['HTC, Pregnancy Status'];
                        var patientAge = patient['age'];
                        var patientGender = patient['gender'];

                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (patientGender == "F" && patientAge > 12) {

                                conditions.enable.push("Cervical Cancer Screening Register");
                        }

                        else {

                                conditions.hide.push("Level of Education");
                        }
                        return conditions;
                }
        },


        'Previous Screening for CACX': function (formName, formFieldValues) {
                var PreviousCancer = formFieldValues['Previous Screening for CACX'];
                var conditions = { show: [], hide: [] };

                if (formName == "Previous Cancer Screening") {
                        if (PreviousCancer == "Yes") {
                                conditions.show.push("CACX Screening Date");
                                conditions.show.push("CACX Screening Results");
                        }
                        else {
                                conditions.hide.push("CACX Screening Date");
                                conditions.hide.push("CACX Screening Results");
                        }
                }
                return conditions;
        },

        'Type of Screening Offered': function (formName, formFieldValues) {
                var CancerAssessment = formFieldValues['Type of Screening Offered'];
                var conditions = { show: [], hide: [] };


             if (formName == "Cervical Cancer Screening Register") {

                  if (CancerAssessment == "VIA Test") {
                     conditions.show.push("VIA Test");
                     conditions.hide.push("Results of Pap Smear");

                   }
                else if (CancerAssessment == "Pap Smear") {
                     conditions.show.push("Results of Pap Smear");
                     conditions.hide.push("VIA Test");

                }

                else if (CancerAssessment == "Both") {
                     conditions.show.push("Results of Pap Smear");
                     conditions.show.push("VIA Test");

                 }

                else {
                        conditions.hide.push("VIA Test");
                        conditions.hide.push("Results of Pap Smear");
                }
                }
                return conditions;
        },

        'HIV Status': function (formName, formFieldValues) {
                var Cancerhivstatusresults = formFieldValues['HIV Status'];
                var conditions = { show: [], hide: [] };

                if (formName == "Cervical Cancer Screening Register") {


                        if (Cancerhivstatusresults == "Positive") {
                                conditions.hide.push("PITC Offered");
                                conditions.hide.push("PITC Results");
                        }


                        else {
                                conditions.show.push("PITC Offered");
                                conditions.show.push("PITC Results");
                        }
                }
                return conditions;
        },


        'Cervical Cancer Assessment Method': function (formName, formFieldValues) {
                var CancerAssessment = formFieldValues['Cervical Cancer Assessment Method'];

                if (formName == "PostNatal Care Register") {
                        var conditions = { show: [], hide: [] };

                        if (CancerAssessment == "VIA") {
                                conditions.show.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                        else if (CancerAssessment == "Pap Smear") {
                                conditions.show.push("Results of Pap Smear")
                                conditions.hide.push("VIA Test");
                        }
                        else {
                                conditions.hide.push("VIA Test")
                                conditions.hide.push("Results of Pap Smear");
                        }
                }
                return conditions;
        },

        'Refer or Consult': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Refer or Consult'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Provide nutritional support or infant feeding") {
                        conditions.show.push("HIVTC, Nutritional products");
                } else {
                        //conditions.hide.push("HIVTC, Nutritional products");
                }
                return conditions;
        },

        /*-----
           'HIVTC, Treatment substituted date' : function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Treatment substituted date'];
                var conditions = {enable: [], disable: [], show: [], hide: []};

                if (conditionConcept){
                    conditions.enable.push("HIVTC, Adult 1st Line Regimen")
                    conditions.enable.push("HIVTC, Adult 2nd Line Regimen")
                    conditions.enable.push("HIVTC, Children 1st Line Regimen")
                    conditions.enable.push("HIVTC, Children 2nd Line Regimen")
                    conditions.enable.push("HIVTC, Adult 3rd Line Regimen")
                    conditions.enable.push("HIVTC, Children 3rd Line Regimen")
                    conditions.enable.push("HIVTC, Reason for treatment substitution");
                }else {
                    conditions.disable.push("HIVTC, Reason for treatment substitution")
                    conditions.disable.push("HIVTC, Adult 1st Line Regimen")
                    conditions.disable.push("HIVTC, Adult 2nd Line Regimen")
                    conditions.disable.push("HIVTC, Adult 3rd Line Regimen")
                    conditions.disable.push("HIVTC, Children 1st Line Regimen")
                    conditions.disable.push("HIVTC, Children 2nd Line Regimen")
                    conditions.disable.push("HIVTC, Children 3rd Line Regimen");
                }
                return conditions;
            },
        -----*/

        'HIVTC, Treatment switched date': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Treatment switched date'];

                var conditions = { enable: [], disable: [] };

                if (conditionConcept) {
                        conditions.enable.push("HIVTC, Reason for treatment switch")
                        conditions.enable.push("HIVTC, Name of Switched Regimen");
                } else {
                        conditions.disable.push("HIVTC, Reason for treatment switch")
                        conditions.disable.push("HIVTC, Name of Switched Regimen");
                }
                return conditions;
        },


        'HIVTC, Viral Load Result': function (formName, formFieldValues, ViralLoadDate) {
                var conditionConcept = formFieldValues['HIVTC, Viral Load Result'];
                var viralloadDate = ViralLoadDate['HIVTC, Viral load blood results return date'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == 'Greater or equals to 20' || 'Less than 20' || 'Undetectable') {
                        //conditions.show.push("HIVTC, Date VL Results received");
                        if (conditionConcept == 'Greater or equals to 20') {
                                conditions.show.push("HIVTC, Viral Load");
                                conditions.show.push("HIVTC, Viral Load Data");
                        }
                        else {
                                conditions.hide.push("HIVTC, Viral Load");
                                conditions.hide.push("HIVTC, Viral Load Data");
                        }
                }
                else {
                        //condition.hide.push("HIVTC, Date VL Results received");
                }

                return conditions;
        },


        'HIVTC, Action to Record Viral Load Results': function (formName, formFieldValues, patient) {
                var conditionConcept = formFieldValues['HIVTC, Action to Record Viral Load Results'];
                var patientAge = patient['age'];
                var patientGender = patient['gender'];
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                if (conditionConcept.includes('Viral Load Result') && !conditionConcept.includes('HIVTC, Draw Blood for VL Test')) {
                        // Visible fields
                        conditions.show.push("HIVTC, Viral Load Result");
                        conditions.show.push("HIVTC, Viral Load Data");
                        conditions.show.push("HIVTC, Viral load blood results return date");
                        conditions.show.push("HIVTC, Date VL Result given to patient");
                        // Hidden fields
                        conditions.hide.push("HIVTC, Viral Load Blood drawn date");
                        conditions.hide.push("HIVTC, VL Pregnancy Status");
                        conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        conditions.hide.push("HIVTC, Viral Load Monitoring Type");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else if (conditionConcept.includes('HIVTC, Draw Blood for VL Test') && !conditionConcept.includes('Viral Load Result')) {
                        conditions.show.push("HIVTC, Viral Load Blood drawn date");
                        conditions.show.push("HIVTC, VL Pregnancy Status");
                        conditions.show.push("HIVTC, VL Breastfeeding Status");
                        conditions.show.push("HIVTC, Viral Load Monitoring Type");
                        // Hidden fields
                        conditions.hide.push("HIVTC, Viral Load Result");
                        conditions.hide.push("HIVTC, Viral Load Data");
                        conditions.hide.push("HIVTC, Viral load blood results return date");
                        conditions.hide.push("HIVTC, Date VL Result given to patient");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else if (conditionConcept.includes('HIVTC, Draw Blood for VL Test') && conditionConcept.includes('Viral Load Result')) {
                        // Visible fields
                        conditions.show.push("HIVTC, Viral Load Result");
                        conditions.show.push("HIVTC, Viral Load Data");
                        conditions.show.push("HIVTC, Viral load blood results return date");
                        conditions.show.push("HIVTC, Date VL Result given to patient");
                        conditions.show.push("HIVTC, Viral Load Blood drawn date");
                        conditions.show.push("HIVTC, VL Pregnancy Status");
                        conditions.show.push("HIVTC, VL Breastfeeding Status");
                        conditions.show.push("HIVTC, Viral Load Monitoring Type");
                        // Hide Pregnancy and Breastfeeding fields for Males and Young children
                        if (patientAge < 12 || patientAge > 49 || patientGender == "M") {
                                conditions.hide.push("HIVTC, VL Pregnancy Status");
                                conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        }
                } else {
                        // Hide everything except Record Viral Load Results field
                        conditions.hide.push("HIVTC, Viral Load Data");
                        conditions.hide.push("HIVTC, Viral load blood results return date");
                        conditions.hide.push("HIVTC, Date VL Result given to patient");
                        conditions.hide.push("HIVTC, Viral Load Blood drawn date");
                        conditions.hide.push("HIVTC, VL Pregnancy Status");
                        conditions.hide.push("HIVTC, VL Breastfeeding Status");
                        conditions.hide.push("HIVTC, Viral Load Monitoring Type");
                        conditions.hide.push("HIVTC, Viral Load Result");
                }
                return conditions;

        },

        'HTC, Pregnancy Status': function (formName, formFieldValues, patient) {
                if ((formName == "HIV Treatment and Care Progress Template") || (formName == "HIVTC, Patient Register")) {
                        var conditionConcept = formFieldValues['HTC, Pregnancy Status'];
                        var patientAge = patient['age'];
                        var patientGender = patient['gender'];

                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (patientGender == "F" && conditionConcept == "Pregnancy") {
                                conditions.show.push("HIVTC, Pregnancy Estimated Date of Delivery");
                                conditions.hide.push("Currently on FP");
                                conditions.hide.push("HIVTC, FP methods used by the patient");
                        }
                        else if ((patientGender == "F" && patientAge > 12 && conditionConcept == "Pregnancy") || patientAge < 5) {
                                conditions.show.push("IMAM, MUAC");
                                if (patientAge < 5) {
                                        conditions.hide.push("HIVTC, Pregnancy Estimated Date of Delivery");
                                        conditions.hide.push("Currently on FP");
                                        conditions.hide.push("HIVTC, FP methods used by the patient");
                                        conditions.hide.push("PMTCT, Referred if the status is unknown");
                                }
                        }

                        else {
                                conditions.hide.push("IMAM, MUAC");
                                conditions.hide.push("HIVTC, Pregnancy Estimated Date of Delivery");
                                conditions.hide.push("Currently on FP");
                                conditions.hide.push("HIVTC, FP methods used by the patient");
                                conditions.hide.push("PMTCT, Referred if the status is unknown");

                        }
                        return conditions;
                }
        },

        'TB Status': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['TB Status'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Suspected / Probable") {
                        conditions.show.push("TB Suspect signs");
                } else {
                        conditions.hide.push("TB Suspect signs");
                }
                return conditions;
        },
        'PNC, HIV Status Known Before Visit': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['PNC, HIV Status Known Before Visit'];
                var conditions = { show: [], hide: [] };
                if (formName == "HIV Prevention, Care, and Treatment") {
                if (conditionConcept == "Positive") {
                        conditions.hide.push("Tested in PNC");
                } else {
                        conditions.show.push("Tested in PNC");
                }

                return conditions;
        }
        },

        /*---------------------HIV Care and Treatment-------------------*/

        'Transfer Out to another site': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Transfer Out to another site'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Transferred out");
                } else {
                        conditions.hide.push("HIVTC, Transferred out");
                }
                return conditions;
        },

        'Type of client': function (formName, formFieldValues, patient) {
                var conditionConcept = formFieldValues['Type of client'];
                var conditions = { show: [], hide: [], enable: [], disable: [] };
                var patientAge = patient['age'];
                var patientGender = patient['gender'];

                /*-- Ensure that the ART regimen field is always disabled --*/
                conditions.disable.push("HIVTC, ART Regimen");


                if (conditionConcept == "ART patient" ) {
                        
                        if ((patientGender == "M") || (patientAge < 12 || patientAge > 50)) {
                       conditions.hide.push("HTC, Pregnancy Status");
                       } 
                       else {
                       conditions.show.push("HTC, Pregnancy Status");
                       }
                       
                       //conditions.show.push("HTC, Pregnancy Status");
                       conditions.show.push("Function");
                       conditions.show.push("HIVTC, HIV care WHO Staging");
                       conditions.show.push("HIVTC, Treatment Staging");
                       conditions.show.push("TB Status");
                       conditions.show.push("TB Suspect signs");
                       conditions.show.push("Sexually Transmitted Infection");
                       conditions.show.push("Potential Side Effects");
                       conditions.show.push("OI, Opportunistic infections");
                       conditions.show.push("Refer or Consult");
                       conditions.show.push("Number of days hospitalised");
              
               } 
               else {
                       
                       conditions.hide.push("HTC, Pregnancy Status");
                       conditions.hide.push("Function");
                       conditions.hide.push("HIVTC, HIV care WHO Staging");
                       conditions.hide.push("HIVTC, Treatment Staging");
                       conditions.hide.push("TB Status");
                       conditions.hide.push("TB Suspect signs");
                       conditions.hide.push("Sexually Transmitted Infection");
                       conditions.hide.push("Potential Side Effects");
                       conditions.hide.push("OI, Opportunistic infections");
                       conditions.hide.push("Refer or Consult");
                       conditions.hide.push("Number of days hospitalised");
                        }

                return conditions;
        },


     /*--- ARV Drug days and drug supply duration generic autocalculations---- */
    'ART, Follow-up date' : function (formName, formFieldValues) {
        if(formName=="HIVTC, Patient Register") {
                 var followUpDate = formFieldValues['ART, Follow-up date'];
                 var conditions = { assignedValues: [], error: [] };
                 var dateUtil = Bahmni.Common.Util.DateUtil;
				 var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                 if(followUpDate) {
                         var daysDispesed;

                         if(!retrospectiveDate) {
                                daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.now(), followUpDate);
                         } else {
                                daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.parse(retrospectiveDate.substr(1, 10)), followUpDate);
                         }

                         // if(daysDispensed <= 0) {
                                 // conditions.error.push("Invalid input for Follow-up Date, must be a date in the future. Please correct.");
                                 // conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed });
                         // } else {
                                 var drugSupplyPeriod = "";

                                 if(daysDispensed >= 10 && daysDispensed < 21) {
                                         // Providing 3 days slack from 2 weeks, in case of weekends or other reasons
                                         drugSupplyPeriod = "HIVTC, Two weeks supply";
                                 } else if (daysDispensed >= 28  && daysDispensed < 56) {
                                         drugSupplyPeriod = "HIVTC, One month supply";
                                 } else if (daysDispensed >= 56 && daysDispensed < 84 ) {
                                         drugSupplyPeriod = "HIVTC, Two months supply";
                                 } else if (daysDispensed >= 84 && daysDispensed < 112) {
                                         drugSupplyPeriod = "HIVTC, Three months supply";
                                 } else if (daysDispensed >= 112 && daysDispensed < 140) {
                                         drugSupplyPeriod = "HIVTC, Four months supply";
                                 } else if (daysDispensed >= 140 && daysDispensed < 168) {
                                         drugSupplyPeriod = "HIVTC, Five months supply";
                                 } else if (daysDispensed >= 168 && daysDispensed < 196) {
                                         drugSupplyPeriod = "HIVTC, Six months supply";
                                 } else if (daysDispensed >= 196) {
                                         drugSupplyPeriod = "HIVTC, Seven+ months supply";
                                 } else {
                                        // No action
                                 }

                                 conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed, autocalculate:true });
                                 conditions.assignedValues.push({ field: "HIVTC, ARV drugs supply duration", fieldValue: drugSupplyPeriod, autocalculate:true });
                         // }
                 }
                 return conditions;
         }
     },

/*--- TB number of days dispensed generic autocalculation----*/
           'TB, Next appointment/refill date' : function (formName, formFieldValues) {
                if(formName=="Tuberculosis Followup Template") {
                         var followUpDate = formFieldValues['TB, Next appointment/refill date'];
                         var conditions = { assignedValues: [], error: [] };
                         var dateUtil = Bahmni.Common.Util.DateUtil;
                                         var retrospectiveDate = $.cookie(Bahmni.Common.Constants.retrospectiveEntryEncounterDateCookieName);

                         if(followUpDate) {
                                 var daysDispesed;

                                 if(!retrospectiveDate) {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.now(), followUpDate);
                                 } else {
                                        daysDispensed = dateUtil.diffInDaysRegardlessOfTime(dateUtil.parse(retrospectiveDate.substr(1, 10)), followUpDate);
                                 }

                                         conditions.assignedValues.push({ field: "ARV drugs No. of days dispensed", fieldValue: daysDispensed,autocalculate:true });

                         }
                         return conditions;
                 }
             },

/*--- EDD generic autocalculation----*/
           'ANC, Last Normal Menstrual Period' : function (formName, formFieldValues) {
                if(formName=="ANC, Obstetric History") {
                         var LNMP = formFieldValues['ANC, Last Normal Menstrual Period'];
                         var conditions = { assignedValues: [], error: [] };
                         var dateUtil = Bahmni.Common.Util.DateUtil;
                         var LNMPDate = new Date(LNMP);
                        //  var EDDWithTime = dateUtil.addMonths(LNMPDate,9);
                         var EDDWithTime = dateUtil.addDays(LNMPDate,280);
                         var EDDWithoutTime = dateUtil.getDateWithoutTime(EDDWithTime);

                         if(LNMP) {

                            conditions.assignedValues.push({ field: "ANC, Estimated Date of Delivery", fieldValue:EDDWithoutTime ,autocalculate:true});

                         }
                         console.log(conditions.assignedValues)
                         return conditions;
                         
                 }
             },

        'HIVTC, Enhanced adherence counseling done': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, Enhanced adherence counseling done'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Enhanced adherence counseling monitoring set");
                } else {
                        conditions.hide.push("HIVTC, Enhanced adherence counseling monitoring set");
                }
                return conditions;
        },

       'HIVTC, HIV care IPT started': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, HIV care IPT started'];
                var conditions = { assignedValues: [],show: [], hide: [] };

                if (conditionConcept == "Treatment complete") {
                        conditions.show.push("HIVTC, TPT completion Date");
                    

                }

                else if (conditionConcept == "Yes") {
                        conditions.show.push("IPT Adherence");
                        conditions.show.push("IPT No. of days dispensed");
                } else {
                        conditions.hide.push("IPT Adherence");
                        conditions.hide.push("IPT No. of days dispensed");
                        conditions.hide.push("HIVTC, TPT completion Date");
                }

                if (formName == "HIVTC, Patient Register" || formName=="HIV Treatment and Care Progress Template" ) {
                        conditions.assignedValues.push({
                            field: "HIVTC, HIV care IPT started",
                            fieldValue: {
                                isAutoFill: true,
                                scopedEncounter: "latestvisit",
                                isFilledOnRetrospectiveMode: true,
                                enableDefaultValue: true,
                                enableEditAfterAutoFill: true
                            }
                        });
                   }
                return conditions;
        },

        'ARV Treatment Substituted': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Substituted'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Treatment Substitution");
                } else {
                        conditions.hide.push("HIVTC, Treatment Substitution");
                }
                return conditions;
        },

        'ARV Treatment Switch to another line': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Switch to another line'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, Treatment Switch");
                } else {
                        conditions.hide.push("HIVTC, Treatment Switch");
                }
                return conditions;
        },

        'ARV Treatment Interrupted': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ARV Treatment Interrupted'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("ARV treatment interruptions Set");
                } else {
                        conditions.hide.push("ARV treatment interruptions Set");
                }
                return conditions;
        },

        'ART test results from Lab': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ART test results from Lab'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("HIVTC, ART Lab Test Results");
                        //conditions.hide.push("HIVTC, Viral load blood results return date");
                        //conditions.hide.push("HIVTC, Viral Load");
                } else {
                        conditions.hide.push("HIVTC, ART Lab Test Results");
                }
                return conditions;
        },


        'ART Treatment interruption type': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['ART Treatment interruption type'];

                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Stopped") {
                        conditions.show.push("ART treatment interruption stopped reason");
                } else {
                        conditions.hide.push("ART treatment interruption stopped reason");
                }
                return conditions;
        },

        'HIVTC, ART Treatment Adherence': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HIVTC, ART Treatment Adherence'];

                var conditions = { show: [], hide: [] };

                if ((conditionConcept == "Poor adherence") || (conditionConcept == "Fair adherence")) {
                        conditions.show.push("Poor or Fair ART adherence reason");
                } else {
                        conditions.hide.push("Poor or Fair ART adherence reason");
                }
                return conditions;
        },

        'HIVTC, Status at enrolment': function (formName, formFieldValues, patient) {
                var patientAge = patient['age'];
                var patientGender = patient['gender'];

                if (patientAge < 1) {
                        return {
                                show: ["ART, HIV Exposed Baby"]
                        }
                } else {
                        return {
                                hide: ["ART, HIV Exposed Baby"]
                        }
                }
        },
        /*--------------------- HIV TESTING AND COUNSELING (HTC)----------------------*/






        // 'HTC, Initial HIV Test Determine': function (formName, formFieldValues, patient) {

        //         if ((formName == "HTC, HIV Test") || (formName == "HIV Testing and Counseling Intake Template") ||
        //                 (formName == "HIV Testing Services Retesting Template")) {
        //                 var determineResult = formFieldValues['HTC, Initial HIV Test Determine'];
        //                 var conditions = { show: [], hide: [], disable: [] };

        //                 if (determineResult == "Positive") {
        //                         conditions.show.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         return conditions;
        //                 }
        //                 if (determineResult == "Negative") {
        //                         for (var i = 0; i < formFieldValues['HTC, Final HIV status'].length, i++) {

        //                         }
        //                         conditions.hide.push("HTC, Linked To Care");
        //                         conditions.disable.push();
        //                         conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory")
        //                         conditions.hide.push("HTC, Repeat HIV Test Determine")
        //                         conditions.hide.push("HTC, Repeat Unigold Test")
        //                         conditions.hide.push("HTC, SD Bioline Tie Breaker")
        //                         conditions.hide.push("HTC, DNA PCR Test Results");
        //                         return conditions;
        //                 }
        //         }

        // },


        'HTC, Initial HIV Test Determine': function (formName, formFieldValues, patient) {

                if ((formName == "HIV Testing and Counseling Intake Template") || (formName == "HTC, HIV Test") || (formName == "HIV Testing Services Retesting Template")) {
                        var determineResult = formFieldValues['HTC, Initial HIV Test Determine'];
                        var conditions = { show: [], hide: [] };

                       if (determineResult == "Positive") {
                                conditions.show.push("HTC, Initial HIV Test Unigold Confirmatory")
                        }
                        else  {
                                conditions.hide.push("HTC, Initial HIV Test Unigold Confirmatory")
                                conditions.hide.push("HTC, Repeat HIV Test Determine")
                                conditions.hide.push("HTC, Repeat Unigold Test")
                                conditions.hide.push("HTC, SD Bioline Tie Breaker")
                                conditions.hide.push("HTC, DNA PCR Test Results");
                        }
                }
                return conditions;
        },


        'HTC, Initial HIV Test Unigold Confirmatory': function (formName, formFieldValues) {

                if ((formName == "HIV Testing and Counseling Intake Template") || (formName == "HIV Testing Services Retesting Template") || (formName == "HTC, HIV Test")) {
                        var unigoldResult = formFieldValues['HTC, Initial HIV Test Unigold Confirmatory'];
                        var determineResults = formFieldValues['HTC, Initial HIV Test Determine'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if ((unigoldResult == "Negative") && (determineResults == "Positive")) {
                                conditions.show.push("HTC, Repeat HIV Test Determine")
                                conditions.show.push("HTC, Repeat Unigold Test");
                        }
                        else {
                                conditions.hide.push("HTC, SD Bioline Tie Breaker")
                                conditions.hide.push("HTC, DNA PCR Test Results")
                                conditions.hide.push("HTC, Repeat HIV Test Determine")
                                conditions.hide.push("HTC, Repeat Unigold Test");

                        }
                        return conditions;
                }
        },

        'HTC, Repeat Unigold Test': function (formName, formFieldValues) {

                if ((formName == "HIV Testing and Counseling Intake Template") || (formName == "HIV Testing Services Retesting Template") || (formName == "HTC, HIV Test")) {
                        var unigoldRepeat = formFieldValues['HTC, Repeat Unigold Test'];
                        var determineRepeat = formFieldValues['HTC, Repeat HIV Test Determine'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if ((unigoldRepeat == "Negative" && determineRepeat == "Positive") || (unigoldRepeat == "Positive" && determineRepeat == "Negative")) {
                                conditions.show.push("HTC, SD Bioline Tie Breaker");
                        }
                        else {
                                conditions.hide.push("HTC, SD Bioline Tie Breaker");

                        }
                        return conditions;
                }
        },

        'HTC, SD Bioline Tie Breaker': function (formName, formFieldValues) {

                if ((formName == "HIV Testing and Counseling Intake Template") || (formName == "HIV Testing Services Retesting Template") || (formName == "HTC, HIV Test")) {
                        var sdBiolineResult = formFieldValues['HTC, SD Bioline Tie Breaker'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (sdBiolineResult == "Positive") {
                                conditions.show.push("HTC, DNA PCR Test Results");
                        }
                        else {
                                conditions.hide.push("HTC, DNA PCR Test Results");

                        }
                        return conditions;
                }
        },

        'ART, Condoms Dispensed': function (formName, formFieldValues) {

                if (formName == "HIV Testing and Counseling Intake Template" || formName == "HTC, Post-test Counseling Set") {
                        var condomDispensed = formFieldValues['ART, Condoms Dispensed'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (condomDispensed == "Yes") {
                                conditions.show.push("HTC, Condom Type Dispensed");
                        }
                        else {
                                conditions.hide.push("HTC, Condom Type Dispensed");

                        }
                        return conditions;
                }
        },

        'HTC, History of Previous Testing': function (formName, formFieldValues) {

                if (formName == "HTC, Pre-test Counseling Set" || formName == "HTC, Pre-test Counseling Set" || formName == "HIV Testing and Counseling Intake Template") {
                        var testingHistory = formFieldValues['HTC, History of Previous Testing'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (testingHistory == "Yes") {
                                conditions.show.push("HTC, Previous result given")
                                conditions.show.push("HTC, Time Since Test");
                        }
                        else {
                                conditions.hide.push("HTC, Previous result given")
                                conditions.hide.push("HTC, Time Since Test");

                        }
                        return conditions;
                }
        },
        'HTC, Partner Testing and Counseling': function (formName, formFieldValues) {

                if (formName == "HIV Testing and Counseling Intake Template" || formName == "HTC, Post-test Counseling Set") {
                        var coupleTest = formFieldValues['HTC, Partner Testing and Counseling'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (coupleTest == "Yes") {
                                conditions.show.push("HTC, Discordant Couple");
                        }
                        else {
                                conditions.hide.push("HTC, Discordant Couple");

                        }
                        return conditions;
                }
        },
        /*-----
        'HTC, Linked To Care' : function (formName, formFieldValues) {

                if((formName=="HIV Testing and Counseling Intake Template") || (formName=="HIV Testing Services Retesting Template") ) {
                        var careLink = formFieldValues['HTC, Linked To Care'];
                        var conditions = {show: [], hide: [], enable: [], disable: []};

                        if(careLink == "Yes") {
                                conditions.show.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        else if(careLink == "Referred") {
                                conditions.show.push("HTC, Referred Facility");
                                conditions.hide.push("HTC, Date Linked To Care");
                        }
                        else{
                                conditions.hide.push("HTC, Date Linked To Care")
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        return conditions;
                }
        },
        -----*/

        'HTC, Linked To Care': function (formName, formFieldValues) {

                if ((formName == "HIV Testing and Counseling Intake Template") || (formName == "HIV Testing Services Retesting Template")) {
                        var careLink = formFieldValues['HTC, Linked To Care'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (careLink == "Yes") {
                                conditions.show.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                                conditions.hide.push("HTC, Specify");
                        }
                        if (careLink == "No") {
                                conditions.show.push("HTC, Specify");
                                conditions.hide.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        else if (careLink == "Referred") {
                                conditions.show.push("HTC, Referred Facility");
                                conditions.hide.push("HTC, Date Linked To Care");
                                conditions.hide.push("HTC, Specify");
                        }
                        else {
                                conditions.hide.push("HTC, Date Linked To Care")
                                conditions.hide.push("HTC, Specify")
                                conditions.hide.push("HTC, Referred Facility");
                        }
                        return conditions;
                }
        },


        'HIVTC, Adult 2nd Line Regimen': function (formName, formFieldValues) {
                var subDate = formFieldValues['HIVTC, Adult 2nd Line Regimen'];

                var conditions = { enable: [], disable: [] };

                if (subDate) {
                        conditions.disable.push("HIVTC, Reason for treatment substitution")
                        conditions.disable.push("HIVTC, Adult 1st Line Regimen")
                        //conditions.disable.push("HIVTC, Adult 2nd Line Regimen")
                        conditions.disable.push("HIVTC, Adult 3rd Line Regimen")
                        conditions.disable.push("HIVTC, Children 1st Line Regimen")
                        conditions.disable.push("HIVTC, Children 2nd Line Regimen")
                        conditions.disable.push("HIVTC, Children 3rd Line Regimen");
                } else {
                        conditions.enable.push("HIVTC, Reason for treatment substitution")
                        conditions.enable.push("HIVTC, Adult 1st Line Regimen")
                        //conditions.enable.push("HIVTC, Adult 2nd Line Regimen")
                        conditions.enable.push("HIVTC, Adult 3rd Line Regimen")
                        conditions.enable.push("HIVTC, Children 1st Line Regimen")
                        conditions.enable.push("HIVTC, Children 2nd Line Regimen")
                        conditions.enable.push("HIVTC, Children 3rd Line Regimen");
                }
                return conditions;
        },

        /*--------------------- SCREENING TOOL FOR HIV TESTING ELIGIBILITY ----------------------*/
        

        'Testing Eligibility, Tested For HIV': function (formName, formFieldValues) {
                if ( formName == "HIV Testing and Counseling Intake Template") {
                        var testedForHIV= formFieldValues['Testing Eligibility, Tested For HIV'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };


                        if (testedForHIV == "No"){
                                conditions.show.push("Test For HIV");
                                
                                //conditions.hide.push("HTC, HIV Test");
                                //conditions.hide.push("HTC, Post-test Counseling Set");
                                conditions.hide.push("ART, Condoms Dispensed");
                                conditions.hide.push("HIVTC, TB Screened");
                                conditions.hide.push("HTS, Referral");
                                conditions.hide.push("Testing Eligibility, Last Test Results");
                                conditions.hide.push("Testing Eligibility, On ART Treatment");
                                conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                                conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                                
                                conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                               
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");


                        }
                        if (testedForHIV == "Yes"){
                          conditions.show.push("Testing Eligibility, Last Test Results");
                          
                          //conditions.hide.push("HTC, Post-test Counseling Set");
                          
                          conditions.hide.push("ART, Condoms Dispensed");
                          conditions.hide.push("HIVTC, TB Screened");
                          conditions.hide.push("HTS, Referral");
                          conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                          conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                          
                          conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                          
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          

                        }
                        else if (!testedForHIV)    { 
                          
                          conditions.hide.push("Self_Test_Buddy");
                          conditions.hide.push("HTC, Post-test Counseling Set");
                          conditions.hide.push("Testing Eligibility, Time Last Test Done");                        
                          conditions.hide.push("HIVTC, TB Screened","HIV, Testing Strategies");
                          conditions.hide.push("HTS, Referral");
                          conditions.hide.push("Testing Eligibility, Provided Adherence Counselling","Testing Eligibility, Last Test Results");
                          conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                          conditions.hide.push("Testing Eligibility, On ART Treatment");
                          conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                          conditions.hide.push("Testing Eligibility, Last 12 Months");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          conditions.hide.push("Test For HIV","HTC, Pre-test Counseling Set");
                          conditions.hide.push("ART, Condoms Dispensed","HTC, Date Of Distribution","HTC, Distribution channel","HTC, Distribution channel","HTC, Distribution Mode","HTC, Kit Collected For","HTC, Key Pop","HTC, Tested for HIV in The Past 12 Months","HTC, HIVST Results");

                        }

                        return conditions;
                }

        },
        'Test For HIV': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var test= formFieldValues['Test For HIV'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };


                        if (test == "Yes") {
                          conditions.show.push("HIV, Testing Strategies");
                          
                         
                          
                          conditions.hide.push("ART, Condoms Dispensed");
                          conditions.hide.push("HIVTC, TB Screened");
                          conditions.hide.push("HTS, Referral");
                          conditions.hide.push("Testing Eligibility, On ART Treatment");
                          conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                          conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                          conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                        }

                       else if (test == "No" || test == "Declined" || !test){
                          conditions.hide.push("HIV, Testing Strategies");
                          
                          
                          conditions.hide.push("HTC, HIV Test");
                          conditions.hide.push("Self_Test_Buddy");
                          conditions.hide.push("HIVTC, TB Screened");
                          conditions.hide.push("HTS, Referral");
                          conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                          conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                          conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          conditions.hide.push("Testing Eligibility, On ART Treatment");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          conditions.hide.push("ART, Condoms Dispensed","HTC, Date Of Distribution","HTC, Distribution channel","HTC, Distribution channel","HTC, Distribution Mode","HTC, Kit Collected For","HTC, Key Pop","HTC, Tested for HIV in The Past 12 Months","HTC, HIVST Results");
                        }
                        

                        return conditions;
                }

        },

       'HIV, Testing Strategies': function (formName, formFieldValues) {
                var testingStrategy = formFieldValues['HIV, Testing Strategies'];

                if (formName == "HIV Testing and Counseling Intake Template") {
                       var conditions = { show: [], hide: [] };
                       conditions.hide.push("Self_Test_Buddy");
                       conditions.hide.push("HTC, Kit Collected For");

                  if (testingStrategy.includes('HIVTC, Rapid Test') && !testingStrategy.includes('HIVTC, Self Test')){
                         
                          conditions.show.push("HTC, Pre-test Counseling Set","HTC, HIV Test","HTC, Post-test Counseling Set");
                          
                          conditions.show.push("ART, Condoms Dispensed");
                          conditions.show.push("HIVTC, TB Screened");
                          conditions.show.push("HTS, Referral");
                          conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                          conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                          conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          conditions.hide.push("Testing Eligibility, On ART Treatment");
                          conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                          conditions.hide.push("HTC, Date Of Distribution");
                          conditions.hide.push("HTC, Distribution channel");
                          conditions.hide.push("HTC, Distribution Mode");
                          conditions.hide.push("HTC, Kit Collected For");
                          conditions.hide.push("Self_Test_Buddy");
                          conditions.hide.push("HTC, Key Pop");
                          conditions.hide.push("HTC, Tested for HIV in The Past 12 Months");
                          conditions.hide.push("HTC, HIVST Results");
                        }
                else if (testingStrategy.includes('HIVTC, Self Test') && !testingStrategy.includes('HIVTC, Rapid Test')) {
                        conditions.show.push("HTC, Date Of Distribution","HTC, Distribution Mode","Self_Test_Buddy", "HTC, Kit Collected For","HTC, Key Pop","HTC, Tested for HIV in The Past 12 Months","HTC, HIVST Results");
                        conditions.hide.push("HTC, Pre-test Counseling Set","HTC, HIV Test","HTC, Post-test Counseling Set");
                       
                        conditions.hide.push("ART, Condoms Dispensed");
                        conditions.hide.push("HIVTC, TB Screened");
                        conditions.hide.push("HTS, Referral");
                        }
                
                 if (testingStrategy.includes('HIVTC, Self Test') && testingStrategy.includes('HIVTC, Rapid Test')){
                  
                  conditions.show.push("HTC, Date Of Distribution","HTC, Distribution Mode", "Self_Test_Buddy", "HTC, Kit Collected For","HTC, Key Pop","HTC, Tested for HIV in The Past 12 Months","HTC, HIVST Results");
                  conditions.show.push("HTC, Pre-test Counseling Set","HTC, Post-test Counseling Set");
                  conditions.show.push("HTC, HIV Test","ART, Condoms Dispensed","HIVTC, TB Screened","HTS, Referral");
                  
                }
                if (!testingStrategy.includes('HIVTC, Self Test') && !testingStrategy.includes('HIVTC, Rapid Test')){
                  conditions.hide.push("HTC, Date Of Distribution");
                  conditions.hide.push("HTC, Distribution channel");
                  conditions.hide.push("HTC, Distribution Mode");
                  conditions.hide.push("HTC, Kit Collected For");
                  conditions.hide.push("Self_Test_Buddy");
                  conditions.hide.push("HTC, Key Pop");
                  conditions.hide.push("HTC, Tested for HIV in The Past 12 Months");
                  conditions.hide.push("HTC, HIVST Results");
                  conditions.hide.push("HTC, Pre-test Counseling Set","HTC, Post-test Counseling Set");
                  conditions.hide.push("ART, Condoms Dispensed");
                  conditions.hide.push("HIVTC, TB Screened");
                  conditions.hide.push("HTS, Referral");
                }


                }


                return conditions;
        },


        'AHD Client': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['AHD Client'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("AHD Details");
                } else {
                        conditions.hide.push("AHD Details");
                }
                return conditions;
        },

        'Detailed TPT Information': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['Detailed TPT Information'];
                var conditions = { show: [], hide: [] };

                if (conditionConcept == "Yes") {
                        conditions.show.push("TPT Information");
                } else {
                        conditions.hide.push("TPT Information");
                }
                return conditions;
        },

        'HTC, Distribution Mode': function (formName, formFieldValues) {
                var conditionConcept = formFieldValues['HTC, Distribution Mode'];
                var conditions = { show: [], hide: [] };                
                conditionConcept = conditionConcept.sort();
                console.log(conditionConcept);
                
                if (JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Secondary', 'HTC, Secondary'])) {
                        conditions.show.push("Self_Test_Buddy");
                        conditions.show.push("HTC, Kit Collected For");

                }else if(JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Primary', 'HTC, Primary','HTC, Secondary', 'HTC, Secondary'])){
                        conditions.show.push("Self_Test_Buddy");
                        conditions.show.push("HTC, Kit Collected For");

                }else if(JSON.stringify(conditionConcept) === JSON.stringify(['HTC, Primary', 'HTC, Primary']) || JSON.stringify(conditionConcept) === JSON.stringify([])){
                        conditions.hide.push("Self_Test_Buddy");
                        conditions.hide.push("HTC, Kit Collected For");
                }
                return conditions;
        },


        'Testing Eligibility, Last Test Results': function (formName, formFieldValues) {
                if ( formName == "HIV Testing and Counseling Intake Template") {
                        var lastTest= formFieldValues['Testing Eligibility, Last Test Results'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };


                        if (lastTest == "Positive") {
                                conditions.show.push("Testing Eligibility, On ART Treatment");
                                conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                                conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                                conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                                conditions.hide.push("HTC, History of Previous Testing","HTC, Pre-test Counseling");
                               

                        }

                        if (lastTest == "Do Not Know" || lastTest == "Negative") {

                                conditions.show.push("Testing Eligibility, Time Last Test Done");
                                conditions.hide.push("Testing Eligibility, On ART Treatment");
                                conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");
                                conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");
                                conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling"); 
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");                               

                        }
                        return conditions;
                }

        },

        'Testing Eligibility, On ART Treatment': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var onART= formFieldValues['Testing Eligibility, On ART Treatment'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };


                        if (onART == "Yes") {
                                conditions.show.push("Testing Eligibility, Provided Adherence Counselling");
                                conditions.hide.push("Testing Eligibility, Counselled & linked to Treatment");                               
                                conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");                               
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                        }

                        if (onART=="No"){
                                conditions.show.push("Testing Eligibility, Counselled & linked to Treatment");
                                conditions.hide.push("Testing Eligibility, Provided Adherence Counselling");                                
                                conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");                        
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                        }
                        return conditions;
                }
        },

        'Testing Eligibility, Time Last Test Done': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var within3months= formFieldValues['Testing Eligibility, Time Last Test Done'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };


                        if (within3months == "Testing Eligibility, Within 3 Months") {
                                conditions.show.push("Testing Eligibility, Reinforced Prevention Counselling");
                                //conditions.hide.push("Testing Eligibility, Last 12 Months");
                                conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");
                        }

                        if (within3months == "Testing Eligibility, More than 3 Months") {
                              conditions.show.push("Testing Eligibility, Last 12 Months");
                              conditions.hide.push("Testing Eligibility, Reinforced Prevention Counselling");
                              conditions.hide.push("Offered prevention Counselling and or Linked to prevention services");

                        }

                        return conditions;
                }

        },

        'Testing Eligibility, Last 12 Months': function (formName, formFieldValues) {
                if (formName == "HIV Testing and Counseling Intake Template") {
                        var months= formFieldValues['Testing Eligibility, Last 12 Months'];
                        var conditions = { show: [], hide: [], enable: [], disable: [] };

                        if (months == "Had sex with more than 1 sexual partner" ||
                            months == "Had unprotected sex with HIV+ partner" ||
                            months == "Had unprotected sex with partner of unknown HIV status" ||
                            months == "Had /currently have genital sores and/ or discharge" ||
                            months == "None") {

                              conditions.show.push("Test For HIV");
                              conditions.hide.push("Offered prevention Counselling and or Linked to prevention services")

                        }
                    


                        return conditions;
                }

        },
/*
       ------------------------------------------------------
                        Contact index tracing formConditions
       -------------------------------------------------------
 */

'HTSIDX, Index accepted Index Testing Service' : function (formName, formFieldValues) {
    var acceptedIndexing = formFieldValues['HTSIDX, Index accepted Index Testing Service'];

    var conditions = {show: [], hide: [], enable: [], disable: []};

    if (acceptedIndexing == "Yes"){
        conditions.show.push("HTSIDX, Index UIC");
        conditions.show.push("HTSIDX, Index Contact Information");

        // Show prior tests conditikons
        conditions.hide.push("HTSIDX, Prior Test Result");
        conditions.hide.push("HTSIDX, Duration since last test");


        // Hide conditions if the contact has prior tests and the client knows their status
        conditions.hide.push("HTSIDX,Tested");
        conditions.hide.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Date partner/child tested");
        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
        conditions.hide.push("HTSIDX,Linked to care and treatment");
        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
        conditions.hide.push("HTSIDX,Referral to Prevention");

    }else {
        conditions.hide.push("HTSIDX, Index UIC");
        conditions.hide.push("HTSIDX, Index Contact Information");
    }
    return conditions;
},

'HTSIDX, Prior Tested Before Status' : function (formName, formFieldValues) {
    var pirorTest = formFieldValues['HTSIDX, Prior Tested Before Status'];

    var conditions = {show: [], hide: [], enable: [], disable: []};

    if (pirorTest == "Yes"){
        var positive_priorTest = formFieldValues['HTSIDX, Prior Test Result'];
        // Show prior tests conditikons
        conditions.show.push("HTSIDX, Prior Test Result");
        conditions.show.push("HTSIDX, Duration since last test");

        // Hide conditions if the contact has prior tests and the client knows their status
        conditions.hide.push("HTSIDX,Tested");
        conditions.hide.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Date partner/child tested");
        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
        conditions.hide.push("HTSIDX,Linked to care and treatment");
        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
        conditions.show.push("HTSIDX,Referral to Prevention");

    }else if (pirorTest == "No"){

        //Hide prior tests conditikons if the
        conditions.hide.push("HTSIDX, Prior Test Result");
        conditions.hide.push("HTSIDX, Duration since last test");

        // Show conditions if the contact has no prior tests and the client knows their status
        conditions.show.push("HTSIDX,Tested");
        conditions.show.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Date partner/child tested");
        conditions.show.push("HTSIDX,Partner/ Child Test Result");
        conditions.show.push("HTSIDX,Linked to care and treatment");
        conditions.show.push("HTSIDX,Partner/Child's PRE/ART Number");
        conditions.show.push("HTSIDX,Referral to Prevention");
    }  else{

        // Show prior tests conditikons
        conditions.hide.push("HTSIDX, Prior Test Result");
        conditions.hide.push("HTSIDX, Duration since last test");

        // Hide conditions if the contact has prior tests and the client knows their status
        conditions.hide.push("HTSIDX,Tested");
        conditions.hide.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Date partner/child tested");
        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
        conditions.hide.push("HTSIDX,Linked to care and treatment");
        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
        conditions.hide.push("HTSIDX,Referral to Prevention");
    }
    return conditions;
},

'HTSIDX,Tested' : function (formName, formFieldValues) {
    var tested = formFieldValues['HTSIDX,Tested'];

    var conditions = {show: [], hide: [], enable: [], disable: []};

    if (tested == "Yes"){
        conditions.show.push("HTSIDX,Partner/ Child Test Result");
        conditions.show.push("HTSIDX,Linked to care and treatment");
        conditions.show.push("HTSIDX,Partner/Child's PRE/ART Number");

        conditions.hide.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Date partner/child tested");
        conditions.show.push("HTSIDX,Referral to Prevention");

    } else if(tested == "No"){

        conditions.show.push("HTSIDX, IF No, why");
        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
        conditions.hide.push("HTSIDX,Linked to care and treatment");
        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");

        conditions.show.push("HTSIDX,Referral to Prevention");
    } else {

        // Did the client test during their visit to the facility
        conditions.hide.push("HTSIDX,Partner/ Child Test Result");
        conditions.hide.push("HTSIDX,Linked to care and treatment");
        conditions.hide.push("HTSIDX,Partner/Child's PRE/ART Number");
    }
    return conditions;
},
  /* Auto populate forms in PNC,REGISTER form */

  'Delivery date and time': function(formName, formFieldValues) {
        var conditions = { assignedValues: [], disable: [] };

        if (formName == "PostNatal Care Register" || formName == "Delivery Information") {
            conditions.assignedValues.push({
                field: "Delivery date and time",
                fieldValue: {
                    isAutoFill: true,
                    scopedEncounter: "latestvisit",
                    isFilledOnRetrospectiveMode: true,
                    enableDefaultValue: true,
                    enableEditAfterAutoFill: true
                }
            });
        }
        return conditions;
    },

    'Mode of Delivery': function(formName, formFieldValues) {
        var conditions = { assignedValues: [], disable: [] };
        var conditionConcept;
        if (formName == "PostNatal Care Register" || formName == "Delivery Information") {
            conditions.assignedValues.push({
                field: "Mode of Delivery",
                fieldValue: {
                    isAutoFill: true,
                    scopedEncounter: "latestvisit",
                    isFilledOnRetrospectiveMode: true,
                    enableDefaultValue: true,
                    enableEditAfterAutoFill: true
                }
            });
        }
        return conditions;
    },
    //Autofill TPT completed date - Litsitso Masoebe and Kgomotjo Seipobi
    'HIVTC, TPT completion Date': function(formName, formFieldValues) {
        var conditions = { assignedValues: [], disable: [] };
        var conditionConcept;
        if (formName == "HIVTC, Patient Register" || formName=="HIV Treatment and Care Progress Template" ) {
            conditions.assignedValues.push({
                field: "HIVTC, TPT completion Date",
                fieldValue: {
                    isAutoFill: true,
                    scopedEncounter: "latestvisit",
                    isFilledOnRetrospectiveMode: true,
                    enableDefaultValue: true,
                    enableEditAfterAutoFill: true
                }
            });

        }
        return conditions;
    }


};
