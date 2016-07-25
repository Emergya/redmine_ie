$(document).ready(function(){

	// En el caso en el que cambio el selector de 'Tipo de petición'.
	$(document).on('change', '#ie_income_expense_tracker_id', function() {
		// Id del tracker
   		tracker_id = $(this).val();

		// Función que recarga los selects del formulario.
   		reloadSelectsField();
	});

	function reloadSelectsField(){
		fields_id = ['amount_field_id','start_date_field','end_date_field'];

		// Se añade los campos personalizados en los selects cuya id este indicada en fields_id.
		for(var i=0; i<fields_id.length; i++){
			// Se elimina los options del select.
			$("#ie_income_expense_"+fields_id[i]).empty();

			// Se añaden los campos del modelo Issue de tipo  para los campos de Fecha Inicio y Fecha Fin.
			if(i == 1 || i == 2){
				addIssueDateFields(i);	
			}

			// Se añaden los campos personalizados.
			addCustomFields(fields_id, i);
		}
	}

	function addIssueDateFields(i){
		// Se hace una llamada AJAX para poder recoger el nombre de los campos en el idioma configurado en el Redmine.
  		 $.ajax({
			url: "/get_issue_date_fields",
			type: "GET",
			success: function(data) { 
				// Introducimos los options al select.
				$.each( data.issue_date_fields, function( key, value ) {
					$("#ie_income_expense_"+fields_id[i]).append("<option value="+ key +">"+ value +"</option>");
				});
			},
			error: function(xhr) { console.log(xhr); }
		});
	}

	function addCustomFields(fields_id, i){
		// Petición para recibir los campos personalizados que pertenecen a ese tracker.
  		 $.ajax({
			url: "/get_custom_fields",
			type: "GET",
			data: { tracker_id: tracker_id },
			success: function(data) { 
				// Introducimos los campos personalizados.
				for(var k=0; k<data.custom_fields.length; k++){	
					$("#ie_income_expense_"+fields_id[i]).append("<option value="+ parseInt(data.custom_fields[k][1]) +">"+ data.custom_fields[k][0] +"</option>");
				}
			},
			error: function(xhr) { console.log(xhr); }
		});	
	}

});