use tokio::sync::watch;

use crate::protocol::BackendState;

#[derive(Clone, Debug)]
pub struct StateStore {
    sender: watch::Sender<BackendState>,
}

impl StateStore {
    pub fn new(initial: BackendState) -> Self {
        let (sender, _) = watch::channel(initial);
        Self { sender }
    }

    pub fn with<R>(&self, read: impl FnOnce(&BackendState) -> R) -> R {
        read(&self.sender.borrow())
    }

    pub fn subscribe(&self) -> watch::Receiver<BackendState> {
        self.sender.subscribe()
    }

    pub fn update(&self, update: impl FnOnce(&mut BackendState) -> bool) {
        self.sender.send_if_modified(|state| {
            if !update(state) {
                return false;
            }
            state.generation = state.generation.wrapping_add(1);
            true
        });
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unchanged_updates_do_not_advance_generation() {
        let state = StateStore::new(BackendState::default());
        state.update(|_| false);
        assert_eq!(state.with(|current| current.generation), 0);

        state.update(|current| {
            current.session_connected = true;
            true
        });
        assert_eq!(state.with(|current| current.generation), 1);
    }
}
