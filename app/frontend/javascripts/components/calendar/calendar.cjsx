DayNames = require './day_names'
Week = require './week'
moment = require 'moment'

module.exports = React.createClass
  displayName: 'Calendar'

  getInitialState: ->
    month: @_getInitialMonth()
    selectedDates: []

  getDefaultProps: ->
    clickable: true
    publicHolidays: []
    approvedDays: []
    monthChanged: () -> {}
    datesChanged: () ->{}


  _getInitialMonth: ->
    if @props.initialMonth != undefined
      @props.initialMonth
    else
      moment().startOf("day")

  componentDidMount: ->
    @setState
      selectedDates: @props.selectedDates

    @_bindKeydown()

  _bindKeydown: ->
    document.onkeydown = (e) =>
      e = e || window.event

      switch e.keyCode
        when 37
          @_handlePreviousMonthClick()
        when 39
          @_handleNextMonthClick()

  componentWillReceiveProps: (nextProps) ->
    @setState
      selectedDates: nextProps.selectedDates

  _handlePreviousMonthClick: () ->
    month = @state.month.add(-1,'M')
    @setState
      month: month

    @props.monthChanged month

  _handleNextMonthClick: () ->
    month = @state.month.add(1,'M')
    @setState
      month: month

    @props.monthChanged month

  _handleAddDate: (date) ->
    dates = @state.selectedDates
    dates.push date

    @setState (previousState, currentProps) ->
      selectedDates: dates

    @props.datesChanged dates

  _handleRemoveDate: (date) ->
    dates = @state.selectedDates
    _.remove dates, (n) ->
      date.isSame n

    @setState (previousState, currentProps) ->
      selectedDates: dates

    @props.datesChanged dates

  _renderWeeks: () ->
    weeks = []
    done = false
    date = @state.month.clone().startOf("month").add("w" -1).day("Monday")
    monthIndex = date.month()
    count = 0

    while not done
      weekProps =
        key: date.toString()
        date: date.clone()
        month: @state.month
        selectedDates: @state.selectedDates
        addDate: @_handleAddDate
        removeDate: @_handleRemoveDate
        publicHolidays: @props.publicHolidays
        approvedDays: @props.approvedDays
        clickable: @props.clickable

      weeks.push <Week {...weekProps}/>

      date.add(1, "w")
      done = count++ > 2 && monthIndex != date.month()
      monthIndex = date.month()

    weeks

  _renderMonthLabel: () ->
    <span>{@state.month.format("MMMM, YYYY")}</span>

  render: () ->
    <div className="calendar">
      <header>
        <i className="fa fa-angle-left" onClick={@_handlePreviousMonthClick}></i>
        {@_renderMonthLabel()}
        <i className="fa fa-angle-right" onClick={@_handleNextMonthClick}></i>
      </header>
      <DayNames />
      {@_renderWeeks()}
    </div>

