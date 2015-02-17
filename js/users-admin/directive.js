AutoPanelUsersAdminApp

	/**
	 Directive to build the HTML for an individual form field in the page modal
	*/
	.directive( 'modalformfield', function(  ){
		return {
			template: function( elem, attr ){
				// Set defaults
				if( attr.fieldname   === undefined ){ attr.fieldname   = ''; }
				if( attr.label       === undefined ){ attr.label       = attr.fieldname; }
				if( attr.placeholder === undefined ){ attr.placeholder = attr.label; }
				if( attr.type        === undefined ){ attr.type        = 'text'; }
				if( attr.arroption   === undefined ){ attr.arroption   = '[]'; }

				var s = '';
				s += '<div class="form-group">';
					s += '<label for="input-' + attr.fieldname + '" class="col-md-2 control-label">' + attr.label + '</label>';
					s += '<div class="col-md-10">';
						if( attr.type!='select' ){
							s += '<input class="form-control" ';
								s += ' type="' + attr.type + '"';
								s += ' id="input-' + attr.fieldname + '"';
								s += ' ng-model="skvActiveUser[\''+attr.fieldname+'\']"';
								s += ' placeholder="' + attr.placeholder + '"';
								s += ' ng-disabled=" activeAction==\'delete\' "';
							s += '>';
						}else{
							s += '<select class="form-control" ';
								s += ' id="input-' + attr.fieldname + '"';
								s += ' ng-model="skvActiveUser[\''+attr.fieldname+'\']"';
								s += ' ng-disabled=" activeAction==\'delete\' "';
							s += '>';
								var arrOption = JSON.parse( attr.arroption );
								for( var id in arrOption ){
									s += '<option value="' + arrOption[id]['value'] + '">' + arrOption[id]['text'] + '</option>';
								}
							s += '</select>';
						}
					s += '</div>';
				s += '</div>';

				return s;
			}
		}
	});
