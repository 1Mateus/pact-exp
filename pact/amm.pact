(module chainbet GOVERNANCE
    @doc "Implements prediction markets MVP on kadena"

    (use coin)

    (defcap GOVERNANCE ()
        @doc "Govenance parameters. In the future will be DAO"
        (enforce-guard (keyset-ref-guard 'swap-ns-admin ))
    )

    (defcap VAULT (id) ())

    (defschema predictions
        @doc "Schema for accounts table".
        title:string ;; what is being betted upon
        description:string ;; brief explanation of what is going on
        initial-date:time
        final-date:time
        total-liquidity:decimal
        total-bets:decimal
        liquidity-tokens-0:decimal
        liquidity-tokens-1:decimal
        settled:bool
        win-side:bool
    )

    (defschema liquidity
        @doc "describes how much liquidity each account contributed to each prediction"
        amount:decimal
    )

    (defschema bets
        @doc "describes all bets made by users"
        owner:keyset
        prediction:string ;; refers to predictions table
        side:bool
        bet-value:decimal
        win-value:decimal
    )

    (deftable prediction-table:{predictions})
    (deftable liquidity-table:{liquidity})
    (deftable bets-table:{bets})

    (defun create-prediction (
            id
            title
            description
            initial-date
            final-date
        )
        @doc "creates a new prediction to be bet upon"
        (with-capability (GOVERNANCE) (
            (require-capability (GOVERNANCE))
            (insert prediction-table id { 
                "title": title, 
                "description": description, 
                "initial-data": initial-date, 
                "final-date": final-date, 
                "total-liquidity": 0.0, 
                "total-bets": 0.0},
                "liquidity-tokens-0":0.0,
                "liquidity-tokens-1":0.0,
                "settled": false,
                "win-side": false)
        )
        (coin.create-account id
            (guard-any
              [
                (create-capability-guard (VAULT id))
                (create-capability-guard (GOVERNANCE))
              ]))
        
        )
    )

    (defun settle-prediction (id result)
        @doc "Adds the result to a prediction after it is finalized"
        (with-capability (GOVERNANCE) (
            (require-capability (GOVERNANCE))
            (with-read prediction-table id { "settled":= settled, "final-date":= final-date }
                (enforce (!settled))
                (bind (chain-data) { "block-time":= now } 
                    (enforce (=< final-data now))
                    (update prediction-table id { "settled":= true, "win-side":result, "final-date":= now })
                )   
            )
        ))
    )

    (defun add-liquidity (account id amount)
        @doc "Anyone can add liquidity to a specific prediction"
        ;; puxar dados da prediction
        (with-read prediction-table id { 
            "settled":= settled, 
            "total-liquidity":= current-liquidity, 
            "liquidity-tokens-0":= total-tokens-0,
            "liquidity-tokens-1":= total-tokens-1,
            "initial-date":= initial-date,
            "final-date":= final-date 
            }
            (enforce (!settled))
            (bind (chain-data) { "block-time":= now } 
                (enforce (=< final-data now))
                (let (liquidity-id (format "{}@{}" [account id]))
                    (with-default-read liquidity-table liquidity-id
                        { "amount": 0 } 
                        { "amount": current-amount }
                        (write liquidity-table liquidity-id {"amount": (+ current-amount amount)})

                        (write prediction-table id {
                            "total-liquidity": (+ current-liquidity amount),
                            "liquidity-tokens-0": ,
                            "liquidity-tokens-1": "",
                        })
                    )
                )
            )  

        )

        (defun calculate-token-liquidity (current-liquidity current-0 current-1 new-amount)
        @doc " "
        )
        ;; enviar coins pro vault
        ;; prediction e liquidity
    )

)