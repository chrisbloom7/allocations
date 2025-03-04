import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="allocation"
export default class extends Controller {
  static targets = ["requestedAllocation", "investor", "results", "investorTemplate", "investorsContainer"]

  connect() {
    this.debouncedAllocate = this.debounce(this.compute, 300);
    this.addInvestor(null, "Mary", 100, 95);
    this.addInvestor(null, "Tim", 2, 1);
    this.addInvestor(null, "Cheryl", 1, 4);
    const firstInvestor = this.investorTargets[0]
    const firstRemovebutton = firstInvestor.querySelector("button")
    firstRemovebutton.classList.add("hidden")
    firstRemovebutton.setAttribute("disabled", true)
    this.requestedAllocationTarget.select()
    this.compute()
  }

  addInvestor(event, name, requested_amount, average_amount) {
    if (event) event.preventDefault();

    const clone = this.investorTemplateTarget.content.cloneNode(true);

    if (name) clone.querySelector("input[name=name]").value = name;
    if (requested_amount) clone.querySelector("input[name=requested_amount]").value = requested_amount;
    if (average_amount) clone.querySelector("input[name=average_amount]").value = average_amount;

    this.investorsContainerTarget.appendChild(clone)
    const newNode = this.investorTargets[this.investorTargets.length - 1]
    newNode.querySelector("input[name=name]").focus();
  }

  removeInvestor(event) {
    event.preventDefault();

    // Don't remove the last one
    if (this.investorTargets.length < 2) return;

    event.currentTarget.closest("[data-allocation-target='investor']").remove();
  }

  compute() {
    const allocationValidity = this.requestedAllocationTarget.validity
    const formData = new FormData();

    if (!allocationValidity.valid) {
      this.resultsTarget.innerHTML = `
        <li class="list-row">
          <div role="alert" class="alert alert-info alert-soft">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Missing total available allocation.</span>
          </div>
        </li>
      `
      return;
    } else {
      formData.append("allocation_amount", this.requestedAllocationTarget.value.trim());
    }

    const inputIsValid = (inputElement) => inputElement.validity.valid;
    const investorsValid = this.investorTargets.every((investorFieldset) => {
      let requiredInputs = investorFieldset.querySelectorAll("input[required]")
      return Array.from(requiredInputs).every((inputElement) => {
        formData.append(`investor_amounts[][${inputElement.name}]`, inputElement.value.trim())
        return inputIsValid(inputElement)
    })
    });

    if (!investorsValid) {
      this.resultsTarget.innerHTML = `
        <li class="list-row">
          <div role="alert" class="alert alert-info alert-soft">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Missing investor information.</span>
          </div>
        </li>
      `
      return;
    }

    fetch("/allocation", { method: "POST", body: formData })
      .then(response => {
        if (!response.ok) {
          this.resultsTarget.innerHTML = `
            <li class="list-row">
              <div role="alert" class="alert alert-error alert-soft">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>Error! Allocation compute failed.</span>
              </div>
            </li>
          `
          console.error(`HTTP error! Status: ${response.status}`);
          return [];
        }

        return response.json()
      })
      .then(data => {
        console.log(data)

        var results = data.investor_amounts.map(investor => `
          <li class="list-row">
            <div class="avatar avatar-placeholder">
              <div class="bg-neutral text-neutral-content w-12 rounded-full">
                <span>${investor.name[0]}</span=>
              </div>
            </div>
            <div>
              <div>${investor.name}</div>
              <div class="text-xs uppercase font-semibold opacity-60">${investor.investment_status.replace("_", " ")}</div>
            </div>
            <div>$${investor.invested}</div>
          </li>
        `
        ).join("");

        results += `
          <li class="list-row border-t-4 mt-4 pt-4">
            <div class="avatar avatar-placeholder">
              <div class="bg-neutral text-neutral-content w-12 rounded-full">
                <span>$</span>
              </div>
            </div>
            <div>
              <div>$${data.allocated} Collected</div>
              <div class="text-xs uppercase font-semibold opacity-60">${data.funding_status.replace("_", " ")}</div>
            </div>
          </li>
        `

        this.resultsTarget.innerHTML = results
      }).catch(error => console.error("Compute error:", error));
  }

  debounce(func, wait) {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), wait);
    };
  }
}
