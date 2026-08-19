<%--
 *  Copyright 2013 Society for Health Information Systems Programmes, India (HISP India)
 *
 *  This file is part of Inventory module.
 *
 *  Inventory module is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  Inventory module is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Inventory module.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  author: ghanshyam
 *  date: 15-june-2013
 *  issue no: #1636
--%>
<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<openmrs:require privilege="Drug order queue" otherwise="/login.htm" redirect="/module/inventory/main.form" />
<%@ include file="../includes/js_css.jsp"%>
<openmrs:globalProperty var="userLocation" key="hospital.location_user" defaultValue="false"/>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/jquery-ui-1.8.2.custom.min.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/ui.core.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/ui.tabs.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/inventory/scripts/common.js"></script>
<link type="text/css" rel="stylesheet"
	href="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/css/start/ui.tabs.css" />
<script type="text/css" rel="stylesheet"
	href="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/css/start/jquery-ui-1.8.2.custom.css"></script>
<link type="text/css" rel="stylesheet"
	href="${pageContext.request.contextPath}/moduleResources/inventory/styles/drug.process.css" />
<script type="text/javascript"
	src="${pageContext.request.contextPath}/moduleResources/inventory/scripts/jquery/jquery.PrintArea.js"></script>
<script type="text/javascript">
// get context path in order to build controller url
	function getContextPath(){		
		pn = location.pathname;
		len = pn.indexOf("/", 1);				
		cp = pn.substring(0, len);
		return cp;
	}
</script>


<style>
@media print {
	.donotprint {
		display: none;
	}
	.spacer {
		margin-top: 40px;
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
	.printfont {
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
}
</style>



<script type="text/javascript">
var isCredit = false;
jQuery(document).ready(function(){ jQuery("#creditheader").hide();
jQuery("#cashheader").hide();
//jQuery("#headerValue").hide();
});
var count=0;
function process(drugId,formulationId,frequencyName,days,comments){

	
jQuery.ajax({
			type : "GET",
			url : getContextPath() + "/module/inventory/processDrugOrder.form",
			data : ({
				drugId			: drugId,
				formulationId		: formulationId,
				frequencyName		: frequencyName,
				days		: days,
				comments		: comments
			}),
			success : function(data) {
				jQuery("#processDrugOrder").html(data);	
				jQuery("#processDrugOrder").show();
			},
			
		});
		
		jQuery("#process"+drugId).attr("disabled", "disabled");
		//jQuery("#headerValue").show();
}

</script>


<script type="text/javascript">
//ghanshyam,4-july-2013, issue no # 1984, User can issue drugs only from the first indent
function issueDrugOrder(listOfDrugQuantity) {
   var availableIdArr=listOfDrugQuantity.split("."); 
   	var totalValue = 0;var totalDisValue=0;
	var preTotal = document.getElementById('totalValue');
   for (var i = 0; i < availableIdArr.length-1; i++) {
	
   var quantity=document.getElementById(availableIdArr[i].toString()+'_quantity').value;
	
   //ghanshyam,5-july-2013, issue no # 1990, User is able to 'finish' without issuing a drug to patient
   if (quantity==null || quantity==""){
       alert("Please enter quantity");
       return false;
     }
   if (quantity!=null || quantity!=""){
	   if(isNaN(quantity)){
	   alert("Please enter quantity in correct format");
	   return false;
	  }
	 }
	 
   if(quantity!="0"){
  
   var drugName=document.getElementById(availableIdArr[i].toString()+'_drugName').value;
   var formulation=document.getElementById(availableIdArr[i].toString()+'_formulation').value;
   var formulationId=document.getElementById(availableIdArr[i].toString()+'_formulationId').value;
   var quant=document.getElementById(availableIdArr[i].toString()+'_quantity').value;
   var frequencyName=document.getElementById(availableIdArr[i].toString()+'_frequencyName').value;
   var noOfDays=document.getElementById(availableIdArr[i].toString()+'_noOfDays').value;
   var comments=document.getElementById(availableIdArr[i].toString()+'_comments').value;
   var price=document.getElementById(availableIdArr[i].toString()+'_price').value;
   var discount = 0;
   var batch=document.getElementById(availableIdArr[i].toString()+'_batchNo').value;
   var expire=document.getElementById(availableIdArr[i].toString()+'_dateexpiry').value;
   //jQuery("#qty"+drugId).append("<span style='margin:5px;'>" + totalValue + "</span>");
   //jQuery("#mrp"+drugId).append("<span style='margin:5px;'>" + waiverPercentage + "</span>");
  //jQuery("#total"+drugId).append("<span style='margin:5px;'>" + totalAmountPayable + "</span>");
  
  	totalValue = (totalValue + price*quant);
  	
  	var total = parseFloat(price) * parseFloat(quant);
    var discountt=0;
    var totalAfterDiscount = total;
 
   if (preTotal != null){
		totalValue = +totalValue + +preTotal.value;
		preTotal.value = totalValue;
		}

   var avaiableId=availableIdArr[i];
   var deleteString = 'deleteInput(\"'+avaiableId+'\")';
   var htmlText =  "<div id='com_"+avaiableId+"_div'>"
	       	 +"<input id='"+avaiableId+"_fName'  name='"+avaiableId+"_fName' type='text' size='20' value='"+drugName+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fFormulationName'  name='"+avaiableId+"_fFormulationName' type='text' size='11' value='"+formulation+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fbatchNo'  name='"+avaiableId+"_fbatchNo' type='hidden' size='11' value='"+batch+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fdateexpiry'  name='"+avaiableId+"_fdateexpiry' type='hidden'  size='11' value='"+expire+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fQuantity'  name='"+avaiableId+"_fQuantity' type='text' size='3' value='"+quant+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fPrice'  name='"+avaiableId+"_fPrice' type='text' size='3' type='hidden' value='"+price+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fTotal'  name='"+avaiableId+"_fTotal' type='text' size='3' value='"+total+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input type='text' " +"id='"+avaiableId+"_fdiscount' " +"name='"+avaiableId+"_fdiscount' " +"value='0' size='6' " +"onkeyup='calculateDrugDiscount("+avaiableId+");' /> %"
	       	 +"<input id='"+avaiableId+"_fDiscountt'  name='"+avaiableId+"_fDiscountt' type='text' size='4' value='"+discountt+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fTotalAfterDiscount'  name='"+avaiableId+"_fTotalAfterDiscount' type='text' size='12' value='"+totalAfterDiscount+"'  readonly='readonly'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fFormulationId'  name='"+avaiableId+"_fFormulationId' type='hidden' value='"+formulationId+"'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fAvaiableId'  name='avaiableId' type='hidden' value='"+avaiableId+"'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fFrequencyName'  name='"+avaiableId+"_fFrequencyName' type='hidden' value='"+frequencyName+"'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fnoOfDays'  name='"+avaiableId+"_fnoOfDays' type='hidden' value='"+noOfDays+"'/>&nbsp;"
	       	 +"<input id='"+avaiableId+"_fcomments'  name='"+avaiableId+"_fcomments' type='hidden' value='"+comments+"'/>&nbsp;"
	       	 +"<input id='drugProcessName'  name='drugProcessName' type='hidden' value='"+drugName+"'/>&nbsp;"
	       	
	       	 //+"<a style='color:red' href='#' onclick='"+deleteString+"' >[X]</a>"	
	       	 +"</div>";
	
   var newElement = document.createElement('div');
   
   newElement.setAttribute("id", avaiableId);   
   newElement.innerHTML = htmlText;
   var fieldsArea = document.getElementById('headerValue');
   fieldsArea.appendChild(newElement);
   
  jQuery("#"+drugName).hide();
   jQuery("#processDrugOrder").hide();
    }
    calculateAllDrugDiscounts();
  }
  	if (preTotal == null){
		var totalText =  "<div id='com_"+avaiableId+"_div'>"
		  +"<tr>"
				 +"<td id='"+avaiableId+"_fTotal'  name='"+avaiableId+"_fTotal'><b>Total Price:</b>"
				 +"<input id='totalValue'  name='totalValue' type='text' size='6' value='"+Math.round(totalValue)+"'  readonly='readonly'/>&nbsp;"
				 +"</td>"
				 +"</tr>"
				 +"</div>";  	
	   var totalElement = document.createElement('div');
	   totalElement.innerHTML = totalText;
		var totalDiv = document.getElementById('totalDiv');
		var totalDisDiv = document.getElementById('totalDisValue');
	   totalDiv.appendChild(totalElement);
	   jQuery("#totalDiv").show();	
	   jQuery("#totalDisValue").show();	
	} 
	
	jQuery("#estTotal").val(jQuery("#totalValue").val());
	
	var total=jQuery("#totalValue").val();
    var waiverPercentage=jQuery("#waiverPercentage").val();
    var waiverAmount=(total*waiverPercentage)/100;
    var totalAmountPay=total-(total*waiverPercentage)/100;
    var tap=Math.round(totalAmountPay);
    jQuery("#totalAmountPayable").val(tap);
    
    var totalPrice=parseInt(quant)*parseInt(price);
    count++;
    var drugIssuedText = "<td>"
				 +count
				 +"</td>"
				 +"<td>"
				 +drugName
				 +"</td>"
				 +"<td>"
				 +formulation
				 +"</td>"
				 +"<td>"
				 +batch
				 +"</td>"
				 +"<td>"
				 +expire
				 +"</td>"
				 +"<td>"
				 +quant
				 +"</td>"
				 +"<td>"
				 +price
				 +"</td>"
				 +"<td>"
				 +total
				 +"</td>"
				 + "<td id='" + avaiableId + "_printDiscountPercent'>0</td>"
                 + "<td id='" + avaiableId + "_printDiscount'>0</td>"
                 + "<td id='" + avaiableId + "_printTotalAfterDiscount'>"
                 + totalAfterDiscount.toFixed(3)
                 + "</td>";
   
   var newElementt = document.createElement('tr');
   newElementt.setAttribute("align", "center");   
   newElementt.innerHTML = drugIssuedText;
   var fieldsAreaa = document.getElementById('drugIssuedheaderValue');
   fieldsAreaa.appendChild(newElementt);

}

function deleteInput(avaiableId) {
	
   var parentDiv = 'headerValue';
   var child = document.getElementById(avaiableId);
   var parent = document.getElementById(parentDiv);
   
   var price = document.getElementById(avaiableId.toString()+'_fPrice').value;
   var quantity=document.getElementById(avaiableId.toString()+'_fQuantity').value;
   var removedTotal = +price* +quantity;

   var preTotal = document.getElementById('totalValue');
   var currentTotal = preTotal.value;
   if( +currentTotal <= +removedTotal){
		 var totalDiv = document.getElementById('totalDiv');
		 while (totalDiv.firstChild) {
			totalDiv.removeChild(totalDiv.firstChild);
			}
		jQuery("#totalDiv").hide();	
		}
	else{
		preTotal.value = (+currentTotal - + removedTotal).toFixed(2)
	}	
   parent.removeChild(child); 
}

</script>

<script type="text/javascript">
function cancel() {
jQuery("#processDrugOrder").hide();
}
</script>

<script type="text/javascript">
function finishDrugOrder(isCreditOrder) {

    var drugProcessName = document.getElementById("drugProcessName");

    // 1. At least one drug selected
    if (drugProcessName == null) {
        alert("Please select at least one drug");
        return false;
    }

    // 2. Validate discount of every selected drug
    var discountFields = jQuery("input[id$='_fdiscount']");

    for (var i = 0; i < discountFields.length; i++) {

        var discountField = jQuery(discountFields[i]);
        var discount = discountField.val();

        if (discount == null || discount == "") {
            alert("Please enter Discount Percentage");
            discountField.focus();
            return false;
        }

        if (isNaN(discount) ||
            parseFloat(discount) < 0 ||
            parseFloat(discount) > 100) {

            alert("Please enter correct Discount Percentage");
            discountField.focus();
            return false;
        }
    }

    /*
    if(jQuery("#waiverPercentage").val()>0 &&
       jQuery("#waiverComment").val()==""){
        alert("Please enter comment");
        return false;
    }
    */

    // 3. Credit / Cash handling
    if (isCreditOrder) {

        // CREDIT
        isCredit = true;

        jQuery("#amountGiven").val("");
        jQuery("#amountReturned").val("");

        jQuery("#amountGiven").attr("disabled", "disabled");
        jQuery("#amountReturned").attr("disabled", "disabled");

    } else {

        // CASH
        isCredit = false;

        if (jQuery("#amountGiven").val() == "") {
            alert("Please enter Amount Given");
            return false;
        }

        if (jQuery("#amountGiven").val() < 0 ||
            !StringUtils.isDigit(jQuery("#amountGiven").val())) {

            alert("Please enter correct Amount Given");
            return false;
        }

       var amgiv = parseFloat(jQuery("#amountGiven").val()) || 0;
       var tamp = parseFloat(jQuery("#totalAmountPayablee").val()) || 0;

       if (amgiv < tamp) {
          alert("Amount Given must be greater than or equal to Total Amount Payable");
          return false;
       }

        if (jQuery("#amountReturned").val() == "") {
            alert("Please enter Amount Returned");
            return false;
        }

        if (jQuery("#amountReturned").val() < 0 ||
            !StringUtils.isDigit(jQuery("#amountReturned").val())) {

            alert("Please enter correct Amount Returned");
            return false;
        }
    }

    // 4. Confirmation
    if (!confirm("Are you sure?")) {
        return false;
    }
    
    //Disable button so user cannot click twice
    jQuery("#subm").attr("disabled", "disabled");
    
    //Print first
    printDiv2();

    // Submit AFTER print window is opened
    setTimeout(function () {
        document.getElementById("finishDrugOrderForm").submit();
    }, 500);

    return false;
  }

function calculateAllDrugDiscounts() {

    var totalPayable = 0;

    var discountFields =
        document.querySelectorAll("input[id$='_fdiscount']");

    for (var i = 0; i < discountFields.length; i++) {

        var discountField = discountFields[i];

        var id = discountField.id.replace("_fdiscount", "");

        var qtyField = document.getElementById(id + "_fQuantity");
        var priceField = document.getElementById(id + "_fPrice");

        if (!qtyField || !priceField) {
            continue;
        }

        var qty = parseFloat(qtyField.value) || 0;
        var price = parseFloat(priceField.value) || 0;
        var discount = parseFloat(discountField.value) || 0;

        var drugTotal = qty * price;
        var discountAmount = (drugTotal * discount) / 100;

        totalPayable += drugTotal - discountAmount;
    }

    // Set field value
    jQuery("#totalAmountPayablee").val(Math.round(totalPayable));
	amountReturnedToPatient();
}

function calculateDrugDiscount(avaiableId) {

    var totalBeforeDiscount = 0;
    var totalDiscount = 0;
    var totalPayable = 0;

    // Get all dynamically created discount fields
    var discountFields = jQuery("input[id$='_fdiscount']");

    for (var i = 0; i < discountFields.length; i++) {

        var discountField = jQuery(discountFields[i]);

        var id = discountField.attr("id").replace("_fdiscount", "");

        var qtyField = jQuery("#" + id + "_fQuantity");
        var priceField = jQuery("#" + id + "_fPrice");

        if (qtyField.length == 0 || priceField.length == 0) {
            continue;
        }

        var qty = parseFloat(qtyField.val());
        var price = parseFloat(priceField.val());
        var discount = parseFloat(discountField.val());

        // Avoid NaN
        if (isNaN(qty)) {
            qty = 0;
        }

        if (isNaN(price)) {
            price = 0;
        }

        if (isNaN(discount)) {
            discount = 0;
        }

        // Validate discount
        if (discount < 0) {
            discount = 0;
            discountField.val(0);
        }

        if (discount > 100) {
            discount = 100;
            discountField.val(100);
        }

        var drugTotal = qty * price;
        
        totalBeforeDiscount += drugTotal;

        var discountAmount = drugTotal * discount / 100;
        
        totalDiscount += discountAmount;
        
        // Total after discount for this drug
        var drugAfterDiscount = drugTotal - discountAmount;
        
        // Update Discount Amount field
        jQuery("#" + id + "_fDiscountt").val(discountAmount);

        // Update Total After Discount field
        jQuery("#" + id + "_fTotalAfterDiscount").val(drugAfterDiscount.toFixed(3));
        
        jQuery("#" + id + "_printDiscountPercent").text(discount);
        jQuery("#" + id + "_printDiscount").text(discountAmount.toFixed(3));
        jQuery("#" + id + "_printTotalAfterDiscount").text(drugAfterDiscount.toFixed(3));

        var drugPayable = drugTotal - discountAmount;

        //totalPayable = totalPayable + drugPayable;
    }
    
    totalPayable = totalBeforeDiscount-totalDiscount;
    
    jQuery("#totalValue").val(totalBeforeDiscount.toFixed(3));
    
    jQuery("#totalDiscount").val(totalDiscount);

    jQuery("#totalAmountPayablee").val(Math.round(totalPayable));
	amountReturnedToPatient();
}
</script>

<script type="text/javascript">
function amountReturnedToPatient() {

    var amountGivenField = jQuery("#amountGiven");
    var totalAmountPayableField = jQuery("#totalAmountPayablee");
    var amountReturnedField = jQuery("#amountReturned");

    if (amountGivenField.length == 0 ||
        totalAmountPayableField.length == 0 ||
        amountReturnedField.length == 0) {
        return;
    }

    var amountGiven = parseFloat(amountGivenField.val());
    var totalAmountPayable = parseFloat(totalAmountPayableField.val());

    // Avoid NaN
    if (isNaN(amountGiven)) {
        amountGiven = 0;
    }

    if (isNaN(totalAmountPayable)) {
        totalAmountPayable = 0;
    }

    var amountReturned = amountGiven - totalAmountPayable;

    // Don't show negative returned amount
    if (amountReturned < 0) {
        amountReturned = 0;
    }

    amountReturnedField.val(Math.round(amountReturned));
}
</script>

<div style="max-height: 50px; max-width: 1800px;">
	<b class="boxHeader">List of drug</b>
</div>
<br />
<input type="hidden" id="patientType" value="${patientType}">
<div id="patientDetails">
	<!--
<div id="patientDetails" style="margin: 10px auto; width: 981px;">
-->
	<table>
		<tr>
			<td>Patient ID :</td>
            <td>&nbsp;&nbsp;&nbsp;</td>
			<td>&nbsp;${patientSearch.identifier}</td>
		</tr>
		<tr>
			<td>Name :</td><td>&nbsp;</td>
			<td>&nbsp;${patientSearch.givenName}&nbsp;
				${patientSearch.familyName}&nbsp;&nbsp;${fn:replace(patientSearch.middleName,","," ")}</td>
		</tr>
        <tr>
        	<td>Age:</td><td>&nbsp;</td>
        	<td><c:choose>
							<c:when test="${patientSearch.age == 0}">&lt 1</c:when>
							<c:otherwise>${patientSearch.age}</c:otherwise>
						</c:choose></td>
      </tr>
        <tr>
        	<td>Gender:</td><td>&nbsp;</td>
        	<td>&nbsp;${patientSearch.gender}</td>
        </tr>
		<tr>
			<td>Date :</td><td>&nbsp;</td>
			<td>${date}</td>
		</tr>
	</table>
</div>

<form id="drugOrderForm"
	action="drugorder.form?patientId=${patientId}&encounterId=${encounterId}&indCount=${serviceOrderSize}&billType=mixed"
	method="POST">
	<table id="myTable" class="tablesorter" class="thickbox">
		<thead>
			<tr>
				<th style="text-align: center;">S.No</th>
				<th style="text-align: center;">Drug Name</th>
				<th style="text-align: center;">Formulation</th>
				<th style="text-align: center;">Frequency</th>
				<th style="text-align: center;">Days</th>
				<th style="text-align: center;">Comments</th>
				<th style="text-align: center;">Action</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="dol" items="${drugOrderList}" varStatus="index">
				<c:choose>
					<c:when test="${index.count mod 2 == 0}">
						<c:set var="klass" value="odd" />
					</c:when>
					<c:otherwise>
						<c:set var="klass" value="even" />
					</c:otherwise>
				</c:choose>
				<tr class="${klass}" id="${dol.inventoryDrug.name}">
					<td align="center">${index.count}</td>
					<td align="center">${dol.inventoryDrug.name}</td>
					<td align="center">${dol.inventoryDrugFormulation.name}-${dol.inventoryDrugFormulation.dozage}</td>
					<td align="center">${dol.frequency.name}</td>
					<td align="center">${dol.noOfDays}</td>
					<td align="center">${dol.comments}</td>
					<td align="center"><input type="button" id="process${dol.inventoryDrug.id}" name="process${dol.inventoryDrug.id}"
						onclick="process(${dol.inventoryDrug.id},${dol.inventoryDrugFormulation.id},'${dol.frequency.name}',${dol.noOfDays},'${dol.comments}');"
						value="Process">
					</td>
				</tr>
			</c:forEach>
		</tbody>
	</table>
</form>

<div id="processDrugOrder"></div>

<!-- Right side div for drug process -->
<div id="finishDrugOrderDiv">
	<form id="finishDrugOrderForm"
		action="drugorder.form?patientId=${patientId}&encounterId=${encounterId}&patientType=${patientType}"
		method="POST" onsubmit="javascript:return finishDrugOrder();">
		<div>
			<input type="button" id="subm" name="subm"
    value="<spring:message code='inventory.drug.process.finish'/>"
    onclick="finishDrugOrder(false);" />

<input type="button" id="sub" name="sub"
    value="<spring:message code='inventory.drug.process.credit'/>"
    onclick="finishDrugOrder(true);" />
				 <input
				type="button" value="<spring:message code='general.cancel'/>"
				onclick="javascript:window.location.href='patientQueueDrugOrder.form'" />
			<input type="button" id="print" name="print"
				value="<spring:message code='inventory.drug.process.print'/>" onClick="printDiv2();"/>
			<!-- 
		    <select name="enctype"  tabindex="20" >
                <c:forEach items="${encounterTypes}" var="enct">
                    <option value="${enct.encounterTypeId}">${enct.name}</option>
                </c:forEach>
            </select>
		 -->
			<input type="button" id="toogleFinishDrugOrderBtn" value="-"
				onclick="toogleFinishDrugOrder(this);" class="min" style="float: right" />
		</div>

		<div id="totalDiv" style="padding: 0.3em; margin: 0.3em 0em; width: 50%; display:none;">
				
		</div>
		
		<div id="headerValue" class="cancelDraggable"
			style="background: #f6f6f6; border: 1px #808080 solid; padding: 0.3em; margin: 0.3em 0em; width:100%;">
		    <input type='text' size='20' value='Drug Name' readonly='readonly' />
			<input type='text' size="11" value='Formulation' readonly="readonly" />
			<input type='text' size="3" value='Qty' readonly="readonly" />
			<input type='text' size="3" value='MRP' readonly="readonly" />
			<input type='text' size="4" value='Total' readonly="readonly" />
			<input type="text" size="7" value="Discount %" readonly="readonly" />
			<input type='text' size="4" value='Discount' readonly="readonly" />
			<input type='text' size="14" value='Total after Discount' readonly="readonly" />
			<hr />	
			</div>
			
		<div>
		Total&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="text" id="totalValue" name="totalValue"
				size="11" value="0" readOnly="true"/>
		</div>
		<div>
		Total Discount&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="text" id="totalDiscount" name="totalDiscount"
				size="11" value="0" readOnly="true"/>
		</div>
		<div>
		Total amount payable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="text" id="totalAmountPayablee" name="totalAmountPayablee"
				size="11" readOnly="true"/>
		</div>
		<div>
		Comment&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" id="waiverComment" name="waiverComment" size="11" class="cancelDraggable"/>
		</div>
		<div>
		Amount Given&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" id="amountGiven" name="amountGiven" size="11" class="cancelDraggable" onkeyup="amountReturnedToPatient();"/>
		</div>
		<div>
		Amount Returned to Patient&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" id="amountReturned" name="amountReturned" size="11" readOnly="true"/>
		</div>
		</div>
			
	</form>
</div>
	<div id="printDiv" style="display: none;"
		style="width: 1280px; font-size: 0.8em">

		<style>
@media print {
	.donotprint {
		display: none;
	}
	.spacer {
		margin-top: 50px;
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
	.printfont {
		font-family: "Dot Matrix Normal", Arial, Helvetica, sans-serif;
		font-style: normal;
		font-size: 14px;
	}
}
</style>


<br><br> 
<div align="center">
  <tr><td style="text-align:center;">
	     <img  type="image" src="../../moduleResources/inventory/Logo_DFY.jpg" align="middle"/>
	     </td>
	     </tr>
		<center><h2>${hospitalName}</h2></center>
</div>  
<div id="creditheader" style="color:red;text-align: center;">CREDIT BILL</div>  
<div id="cashheader" style="color:red;text-align: center;">CASH BILL</div>  
		<table align='Center'>
		<tr><td>BILL NO.:${isdpdt}</td></tr>
		<tr>
			<td>Patient ID :</td>
			<td>${patientSearch.identifier}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			
			<td>Name :</td>
			<td>${patientSearch.givenName}&nbsp;${patientSearch.familyName}</td>
		</tr>
        <tr>
        	<td>Age:</td>
			<td><c:choose>
							<c:when test="${patientSearch.age == 0}">&lt 1</c:when>
							<c:otherwise>${patientSearch.age}</c:otherwise>
						</c:choose>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
					
			<td>Gender:</td>
        	<td>${patientSearch.gender}</td>  	
      </tr>
      <tr>
     <c:if test="${not empty dohId}">
			<td id="doh">DoH Id:</td>
			<td id="dohid">${dohId}</td>
			</c:if>
      
      </tr>
		<tr>
			<td>Date :</td>
			<td>${date}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			
			<td>Patient Category:</td>
			<td>${patientCategory} &nbsp;&nbsp;&nbsp; ${patientSubCategory}</td>
		</tr>
		</table>
 <hr  color="black">
<table style="width:100%; margin-top:15px">
<thead>
<h4 align="left" style="color:black">Drugs Issued by Pharmacy</h4>
<tr>
<th style="text-align: center;">S.No</th>
<th style="text-align: center;">Drug Name</th>
<th style="text-align: center;">Formulation</th>
<th style="text-align: center;">Batch No.</th>
<th style="text-align: center;">Date Of Expiry</th>
<th style="text-align: center;">Qty</th>
<th style="text-align: center;">MRP</th>
<th style="text-align: center;">Total</th>
<th style="text-align: center;">Discount %</th>
<th style="text-align: center;">Discount</th>
<th style="text-align: center;">Total after Discount</th>
</tr>
</thead>
<tbody id="drugIssuedheaderValue">
</tbody>
</table>

<table style="width:100%">
<tr>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">Total amount</td>
<td style="text-align: center;"><span id="printableTotal" /></td>
</tr>
<tr>
	<td style="text-align: center;">&nbsp;</td>
	<td style="text-align: center;">&nbsp;</td>
	<td style="text-align: center;">&nbsp;</td>
	<td style="text-align: center;">&nbsp;</td>
	<td style="text-align: center;">Discount Amount</td>
	<td style="text-align: center;"><span id="printableDiscountAmount" /></td>
</tr>
<tr>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">Total amount payable</td>
<td style="text-align: center;"><span id="printableTotalAmountPayable" /></td>
</tr>
<!--  <tr>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td id="amtgiven" style="text-align: center;">Amount Given</td>
<td id="amtgivn" style="text-align: center;"><span id="printableGiven" /></td>
</tr>
<tr>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td style="text-align: center;">&nbsp;</td>
<td id="amtreturned" style="text-align: center;">Amount Returned</td>
<td id="amtreturnd" style="text-align: center;"><span id="printableAmountReturned" /></td>
</tr>-->
<tr>
	<td><b>Comment: </b><span id="printableDiscountComment"></span></td>
</tr>
<tr>
<td><b>Total Amount  Payable Rupees:</b><span id="printableTotalPayable" > </span> only</td>
</tr>
</table>

<c:choose>
<c:when test="${not empty drugOrderListNotAvailable}">
<hr  color="black">
<table id="drugNotAvailable" class="tablesorter" class="thickbox" style="width:100%; margin-top:15px">
		<thead>
			<h4 align="left" style="color:black">Drugs Not Issued by Pharmacy</h4>
			<tr>
				<th style="text-align: center;">S.No</th>
				<th style="text-align: center;">Drug Name</th>
				<th style="text-align: center;">Formulation</th>
				<th style="text-align: center;">Days</th>
				<th style="text-align: center;">Frequency</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="dol" items="${drugOrderListNotAvailable}" varStatus="index">
				<c:choose>
					<c:when test="${index.count mod 2 == 0}">
						<c:set var="klass" value="odd" />
					</c:when>
					<c:otherwise>
						<c:set var="klass" value="even" />
					</c:otherwise>
				</c:choose>
				<tr class="${klass}" id="${dol.inventoryDrug.name}">
					<td align="center">${index.count}</td>
					<td align="center">${dol.inventoryDrug.name}</td>
					<td align="center">${dol.inventoryDrugFormulation.name}-${dol.inventoryDrugFormulation.dozage}</td>
					<td align="center">${dol.noOfDays}</td>
					<td align="center">${dol.frequency.name}</td>
				</tr>
			</c:forEach>
		</tbody>
</table>
</c:when>
</c:choose>
<br><br><br><br><br><br><br>
<table  class="spacer" style="margin-left: 60px;width:100%;">
				<tr>
					<td align="right"><b>Treating Doctor</b></td><td>:${doctor}</td>
				</tr>
				<tr>
					<td align="right"><b>Treating Paharmacist</b></td><td>:${pharmacist}</td>
				</tr>
</table>


</div>



<script type="text/javascript">
	function printDivNoJQuery() {
		var divToPrint = document.getElementById('printDiv');
		var newWin = window
				.open('', '',
						'letf=0,top=0,width=1,height=1,toolbar=0,scrollbars=0,status=0');
		newWin.document.write(divToPrint.innerHTML);
		newWin.print();
		newWin.close();
		alert("Printing ...");
		//setTimeout(function(){window.location.href = $("#contextPath").val()+"/getBill.list"}, 1000);	
	}
	function credit() {

    isCredit = true;
    // Clear cash payment fields
    jQuery("#amountGiven").val("");
    jQuery("#amountReturned").val("");

    // Disable cash payment fields
    jQuery("#amountGiven").attr("disabled", "disabled");
    jQuery("#amountReturned").attr("disabled", "disabled");

    // Hide cash payment fields in print
    jQuery("#amtgiven").hide();
    jQuery("#amtreturned").hide();
    jQuery("#amtgivn").hide();
    jQuery("#amtreturnd").hide();

    // Show CREDIT bill
    jQuery("#creditheader").show();

    // Hide CASH bill
    jQuery("#cashheader").hide();
}
	function printDiv2() {

    // ==========================================
    // 1. Get overall values
    // ==========================================

    var totalValue = parseFloat(jQuery("#totalValue").val()) || 0;

    var totalDiscount = parseFloat(jQuery("#totalDiscount").val()) || 0;

    var totalAmountPayable =
        parseFloat(jQuery("#totalAmountPayablee").val()) || 0;

    var waiverComment = jQuery("#waiverComment").val() || "";

    var amountGiven = jQuery("#amountGiven").val() || "";
    var amountReturned = jQuery("#amountReturned").val() || "";


    // ==========================================
    // 2. Clear old printable values
    // ==========================================

    jQuery("#printableTotal").empty();
    jQuery("#printableDiscount").empty();
    jQuery("#printableDiscountAmount").empty();
    jQuery("#printableDiscountComment").empty();
    jQuery("#printableTotalAmountPayable").empty();
    jQuery("#printableTotalPayable").empty();
    jQuery("#printableGiven").empty();
    jQuery("#printableAmountReturned").empty();


    // ==========================================
    // 3. Cash / Credit header
    // ==========================================

   if (isCredit) {
    jQuery("#creditheader").show();
    jQuery("#cashheader").hide();
} else {
    jQuery("#creditheader").hide();
    jQuery("#cashheader").show();
}


    // ==========================================
    // 4. Put values into print section
    // ==========================================

    jQuery("#printableTotal").text(totalValue);

    // This is total discount amount
    jQuery("#printableDiscountAmount").text(totalDiscount);


    jQuery("#printableDiscountComment").text(
        waiverComment
    );

    jQuery("#printableTotalAmountPayable").text(
        Math.round(totalAmountPayable)
    );

    jQuery("#printableTotalPayable").text(
         toWords(String(Math.round(totalAmountPayable)))
    );


    // ==========================================
    // 5. Amount given / returned
    // ==========================================

    if (amountGiven != "") {

        jQuery("#printableGiven").text(
            amountGiven
        );

        jQuery("#printableAmountReturned").text(
            amountReturned
        );
    }


    // ==========================================
    // 6. Open print window
    // ==========================================

    var printContents =
        document.getElementById("printDiv").innerHTML;

    var printer = window.open(
        "",
        "",
        "width=800,height=600"
    );

    if (!printer) {
        alert("Please allow pop-ups to print the bill.");
        return false;
    }

    printer.document.open();

    printer.document.write(
        "<html>" +
        "<head>" +
        "<title>Bill</title>" +

        "<style>" +
        "body { font-family: Arial, Helvetica, sans-serif; font-size: 12px; }" +
        "table { border-collapse: collapse; }" +
        "th, td { padding: 4px; }" +
        "</style>" +

        "</head>" +
        "<body>" +

        printContents +

        "</body>" +
        "</html>"
    );

    printer.document.close();

    // Wait until print document is loaded
    printer.onload = function() {
        printer.focus();
        printer.print();
        printer.close();
    };

    return true;
}

</script>


<%@ include file="/WEB-INF/template/footer.jsp"%>
