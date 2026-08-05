/**
 * 
 */
package org.openmrs.module.inventory.dto;

import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugTransactionDetail;

/**
 * @author Ghanshyam
 *
 */
public class InterDepartmentTransferDTO {

	private InventoryStoreDrugTransactionDetail transactionDetail;
    private InventoryStore destinationStore;
    private Integer quantity;
	public InventoryStoreDrugTransactionDetail getTransactionDetail() {
		return transactionDetail;
	}
	public void setTransactionDetail(InventoryStoreDrugTransactionDetail transactionDetail) {
		this.transactionDetail = transactionDetail;
	}
	public InventoryStore getDestinationStore() {
		return destinationStore;
	}
	public void setDestinationStore(InventoryStore destinationStore) {
		this.destinationStore = destinationStore;
	}
	public Integer getQuantity() {
		return quantity;
	}
	public void setQuantity(Integer quantity) {
		this.quantity = quantity;
	}
	
}
