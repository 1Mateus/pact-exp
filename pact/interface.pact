(interface interface-chainbet
    (defun create-prediction (event-code:string, inicial-liquidity:integer)
      @doc "Only owner, creates new bet event and provides liquidity"
    )

    (defun settle-prediction ()
        @doc "Provides the result of a prediction and settles all bets"
    )

    (defun add-liquidity ()
        @doc "Adds liquidity to  given event"
    )

    (defun redeem-liquidity ()
        @doc "Removes liquidity from protocol after settlement"
    )

    (defun bet (event-code:integer, side:bool, value:integer)
        @doc "user bets in a given option"
    )

    (defun redeem-tickets ()
        @doc "redeems bet tickets after settlement"
    )
)