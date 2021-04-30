function main(){
    return {
        show: false,
        tab: '0',
        wallet: 0,
        balance: 0,
        deposit: 0,
        withdraw: 0,
        dalert: false,
        walert: false,
        talert: false,
        bplayer: 1,
        transfer: 0,
        close(){
            postData('http://h-banking/escape')
            this.show = false
        },
        dp(){
            postData('http://h-banking/deposit', {amount: this.deposit}).then( data =>{
                this.wallet = data.wallet
                this.balance = data.bank
            }
            )
            this.dalert = true
            setTimeout(() => {
                this.dalert = false
            }, 800)
        },
        trf(){
            postData('http://h-banking/transfer', {bplayer: this.bplayer, amount: this.transfer})
            this.talert = true
            setTimeout(() => {
                this.talert = false
            }, 800)
        },
        wh(){
            postData('http://h-banking/withdraw', {amount: this.withdraw})
            this.walert = true
            setTimeout(() => {
                this.walert = false
            }, 800)
        },
        listen(){
            window.addEventListener('message', (event) => {
                let data = event.data
                this.show = data.show
                this.balance = Intl.NumberFormat().format(data.bank)
                this.wallet = Intl.NumberFormat().format(data.wallet)
            })
        }
    }
}

async function postData(url = '', data = {}) {
    const response = await fetch(url, {
      method: 'POST', // *GET, POST, PUT, DELETE, etc.
      mode: 'cors', // no-cors, *cors, same-origin
      cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow',
      referrerPolicy: 'no-referrer',
      body: JSON.stringify(data)
    });
    return response.json();
  }
