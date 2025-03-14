import sublime
import sublime_plugin


def horizontal_layout(groups):
    layouts = [
        {
            'cols': [0.0, 1.0],
            'rows': [0.0, 1.0],
            'cells': [
                [0, 0, 1, 1]
            ],
        },
        {
            'cols': [0.0, 0.5, 1.0],
            'rows': [0.0, 1.0],
            'cells': [
                [0, 0, 1, 1],
                [1, 0, 2, 1]
            ],
        },
        {
            'cols': [0.0, 0.33, 0.66, 1.0],
            'rows': [0.0, 1.0],
            'cells': [
                [0, 0, 1, 1],
                [1, 0, 2, 1],
                [2, 0, 3, 1]
            ],
        },
    ]
    max_groups = len(layouts)
    if (groups < 0 or groups > max_groups - 1):
        raise AttributeError('only {} groups are handled by this layout ; given: {}'.format(max_groups, groups))
    return layouts[groups]


def vertical_layout(groups):
    layouts = [
        {
            'cols': [0.0, 1.0],
            'rows': [0.0, 1.0],
            'cells': [
                [0, 0, 1, 1]
            ],
        },
        {
            'cols': [0.0, 1.0],
            'rows': [0.0, 0.5, 1.0],
            'cells': [
                [0, 0, 1, 1],
                [0, 1, 1, 2]
            ],
        },
        {
            'cols': [0.0, 1.0],
            'rows': [0.0, 0.33, 0.66, 1.0],
            'cells': [
                [0, 0, 1, 1],
                [0, 1, 1, 2],
                [0, 2, 1, 3]
            ],
        },
    ]
    max_groups = len(layouts)
    if (groups < 0 or groups > max_groups - 1):
        raise AttributeError('only {} groups are handled by this layout ; given: {}'.format(max_groups, groups))
    return layouts[groups]


def can_jump_prev(window):
    active_group = window.active_group()
    total_groups = window.num_groups()
    alone_in_group = tabs_in_group(window, window.active_group()) == 1
    in_first_group = active_group == 0
    in_last_group = active_group == total_groups - 1

    return in_last_group or not (in_first_group or alone_in_group)


def can_jump_next(window):
    active_group = window.active_group()
    total_groups = window.num_groups()
    alone_in_group = tabs_in_group(window, window.active_group()) == 1
    in_last_group = active_group == total_groups - 1
    max_reached = total_groups == 3
    in_last_available_group = in_last_group and max_reached

    return not alone_in_group and not in_last_available_group


def tabs_in_group(window, group):
    return len(window.views_in_group(group))


class MoveTabCommand(sublime_plugin.WindowCommand):
    def run(self, same_group=False, backward=False):
        config = (same_group, backward)
        if (config == (True, True)):
            self.move_prev()
        if (config == (True, False)):
            self.move_next()
        if (config == (False, True)):
            self.jump_prev()
        if (config == (False, False)):
            self.jump_next()

    def jump_prev(self):
        window = self.window
        active_group = window.active_group()
        total_groups = window.num_groups()

        if (not can_jump_prev(window)):
            return

        self.window.run_command(
            'move_to_neighboring_group',
            {'forward': False}
        )
        self.window.focus_group(active_group - 1)

        last_group_is_empty = tabs_in_group(window, window.num_groups() - 1) == 0

        if (last_group_is_empty):
            layout_index = total_groups - 2
            self.window.run_command(
                'set_layout',
                self.current_layout(layout_index)
            )

    def jump_next(self):
        window = self.window
        active_group = window.active_group()
        total_groups = window.num_groups()
        in_last_group = active_group == total_groups - 1

        if (not can_jump_next(window)):
            return

        if (in_last_group):
            self.window.run_command(
                'set_layout',
                self.current_layout(total_groups)
            )

        self.window.focus_group(active_group)
        self.window.run_command('move_to_neighboring_group')
        self.window.focus_group(active_group + 1)

    def move_prev(self):
        view = self.window.active_view()
        group, index = self.window.get_view_index(view)
        if index <= 0:
            self.jump_prev()
            return
        self.window.set_view_index(view, group, index - 1)
        self.window.focus_view(view)

    def move_next(self):
        view = self.window.active_view()
        group, index = self.window.get_view_index(view)
        count = len(self.window.views_in_group(group))
        if index >= count - 1:
            self.jump_next()
            return
        self.window.set_view_index(view, group, index + 1)
        self.window.focus_view(view)

    def current_layout(self, groups):
        current = mtc_settings.get("layout", "horizontal")
        if (current == "vertical"):
            return vertical_layout(groups)
        else:
            return horizontal_layout(groups)


def plugin_loaded():
    global mtc_settings
    mtc_settings = sublime.load_settings('move-tab-command.sublime-settings')
