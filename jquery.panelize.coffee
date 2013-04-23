if typeof Object.create isnt 'function'
    Object.create = (obj) ->
        F = ->
        F:: = obj
        new F()


(($, window, document, undefined_) ->
    Panelize = {
        init: (elements, options) ->
            self = @
            # get default elements for rest of plugin
            self.options = $.extend({}, $.fn.panelize.options, options)
            self.outerContainer = elements
            self.panels = elements.children()
            if self.options.containerSelector isnt null
                self.innerContainers = elements.find(self.options.containerSelector)
            else
                self.innerContainers = self.panels.children()
                self.options.containerSelector = self.innerContainers.first().prop('tagName')

            # set z-index properties for panel elements
            count = self.options.startZ
            self.panels.each ->
                $(@).css('z-index', count)
                count -= self.options.zStep
                return

            # set default height for panels
            self.resize()

            self.panels.css({
                'padding-bottom': $(window).height()
                'position': 'fixed'
                'left': 0
                'top': 0
            }).addClass('static')


            self.panels.first().css('position', 'relative').removeClass('static').addClass('scroll')
            self.panels.last().css('padding-bottom', 0)

            lastPosition = 0

            $(window).on 'scroll', ->
                position = $(@).scrollTop()
                #$('#location').html('Top: '+ $(@).scrollTop())
                if(position > lastPosition)
                    # down
                    $element = $('.scroll').last().find('.container')

                    if(($element.offset().top + $element.outerHeight()) <= position)
                        $('.scroll').last().css 'padding-bottom', 0
                        $('.static').first().addClass('scroll').removeClass('static').css 'position', 'relative'
                else
                    #up
                    $element = $('.scroll').last().find('.container')
                    #$('#div-pos').html('Element Top: ' + $element.offset().top)

                    if($element.offset().top > position)
                        if($('.scroll').length > 1)
                            $('.scroll').last().addClass('static').removeClass('scroll')
                            $('.scroll').last().css 'padding-bottom', $(window).height()
                            $('.static').first().css 'position', 'fixed'

                lastPosition = position
                return
            return self.outerContainer

        slide: (id) ->
            self = @
            curPos = $(window).scrollTop()
            dest = self.locations[id]
            time = (Math.abs(curPos - dest) / self.options.speed) * 1000
            $('html,body').animate {
                scrollTop: dest
            }, time
            return self.outerContainer
        resize: ->
            self = @
            self.setHeights()
            setTimeout (->
                self.setOffsets()
            ), 300
            return self.outerContainer
        setHeights: ->
            self = @

            # Set minimum heights for panels to match browser height
            self.innerContainers.css('min-height', $(window).height())
            self.outerContainer.css('min-height', self.getOuterHeight())
            return self.outerContainer
        setOffsets: ->
            self = @

            # Get top offsets fore each panel. This will be used
            # for scrolling between panels
            self.locations = {}
            startingPos = 0
            self.panels.each ->
                height = $(@).find(self.options.containerSelector).outerHeight()
                startingPos += height
                self.locations['#'+$(@).attr('id')] = startingPos - height
                return
            return self.outerContainer
        getOuterHeight: ->
            self = @
            height = 0
            self.innerContainers.each ->
                height += $(@).outerHeight()
                return
            return height

    }

    $.fn.panelize = () ->
        if not $.fn.panelize.instance?
            $.fn.panelize.instance = Object.create(Panelize)
        if typeof arguments[0] is 'object' or arguments[0] is undefined
            return $.fn.panelize.instance.init(@, arguments[0])
        else if arguments[0] is 'resize'
            return $.fn.panelize.instance.resize()
        else if arguments[0] is 'slide' and arguments[1]?
            return $.fn.panelize.instance.slide(arguments[1])
        else
            $.error('Method '+method+' does not exists on jQuery.panelize');


    $.fn.panelize.options = {
        containerSelector: null
        speed: 1000
        startZ: 1000
        zStep: 50
    }
) jQuery, window, document